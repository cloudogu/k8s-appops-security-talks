#!groovy
@Library('github.com/cloudogu/ces-build-lib@9857cf1e')
import com.cloudogu.ces.cesbuildlib.*

node('docker') {

    properties([
            // Keep only the last 10 build to preserve space
            buildDiscarder(logRotator(numToKeepStr: '10')),
            // Don't run concurrent builds for a branch, because they use the same workspace directory
            disableConcurrentBuilds(),
            parameters([
                    booleanParam(name: 'deployToNexus', defaultValue: false,
                            description: 'Deploying to Nexus tages ~10 Min since Nexus 3. That\'s why we skip it be default'),
                    booleanParam(name: 'deployToK8s', defaultValue: false,
                            description: 'Deploys to Kubernetes. We deploy to GitHub pages, so skip deploying to k8s by default.')
            ])
    ])

    Maven mvn = new MavenInDocker(this, "3.5.0-jdk-8")
    Git git = new Git(this, 'cesmarvin')

    String conferenceName = '2019-09-26-heise-devsec'

    titleSlidePath   = 'docs/slides/00-title.md'

    catchError {

        stage('Checkout') {
            checkout scm
            git.clean('')
        }

        String versionName = createVersion()


        stage('Build') {
            new Docker(this).image('node:8.11.3-jessie').mountJenkinsUser()
              // override entrypoint, because of https://issues.jenkins-ci.org/browse/JENKINS-41316
              .inside('--entrypoint=""') {
                echo 'Building presentation'
                sh 'yarn install'
                sh 'node_modules/grunt/bin/grunt package'
            }
            archive 'reveal-js-presentation.zip'
        }

        stage('package') {
            // This could probably be done easier...
            docker.image('garthk/unzip')
               // override entrypoint, because of https://issues.jenkins-ci.org/browse/JENKINS-41316
              .inside('--entrypoint=""') {
                sh 'unzip reveal-js-presentation.zip -d dist'
            }

            writeVersionNameToIntroSlide(versionName)
        }

        stage('Deploy GH Pages') {
            git.pushGitHubPagesBranch('dist', versionName, conferenceName)
        }

        stage('Deploy Nexus') {
            if (params.deployToNexus) {
                String usernameProperty = "site_username"
                String passwordProperty = "site_password"

                String settingsXmlPath = mvn.writeSettingsXmlWithServer(
                        // From pom.xml
                        'ecosystem.cloudogu.com',
                        "\${env.${usernameProperty}}",
                        "\${env.${passwordProperty}}")

                withCredentials([usernamePassword(credentialsId: 'jenkins',
                        passwordVariable: passwordProperty, usernameVariable: usernameProperty)]) {

                    // Deploys to nexus/service/local/repositories/Cloudogu-Docs/content/com.cloudogu.slides/BRANCH_NAME/latest/index.html#/
                    mvn "site:deploy -s \"${settingsXmlPath}\"" +
                            // Use a different artifact for each branch
                            " -Dartifact=${env.BRANCH_NAME} " +
                            // Keep only latest version in Nexus --> Constant URL
                            " -Drevision=latest"
                }
            } else {
                echo "Skipping deployment to Nexus because parameter is set to false."
            }
        }

        stage('Deploy Kubernetes') {
            if (params.deployToK8s) {
                deployToKubernetes(versionName)
            } else {
                echo "Skipping deployment to Kubernetes because parameter is set to false."
            }
        }
    }

    mailIfStatusChanged(git.commitAuthorEmail)
}

String createVersion() {
    // E.g. "201708140933-1674930"
    String versionName = "${new Date().format('yyyyMMddHHmm')}-${new Git(this).commitHashShort}"

    currentBuild.description = versionName
    echo "Building version $versionName on branch ${env.BRANCH_NAME}"
    
    return versionName
}

def titleSlidePath = ''

private void writeVersionNameToIntroSlide(String versionName) {
    def distIntro = "dist/${titleSlidePath}"
    String filteredIntro = filterFile(distIntro, "<!--VERSION-->", "Version: $versionName")
    sh "cp $filteredIntro $distIntro"
    sh "mv $filteredIntro $titleSlidePath"
}

/**
 * Filters a {@code filePath}, replacing an {@code expression} by {@code replace} writing to new file, whose path is returned.
 *
 * @return path to filtered file
 */
String filterFile(String filePath, String expression, String replace) {
    String filteredFilePath = filePath + ".filtered"
    // Fail command (and build) file not present
    sh "test -e ${filePath} || (echo Title slide ${filePath} not found && return 1)"
    sh "cat ${filePath} | sed 's/${expression}/${replace}/g' > ${filteredFilePath}"
    return filteredFilePath
}


void deployToKubernetes(String versionName) {

    String dockerRegistry = 'eu.gcr.io/cloudogu-backend'
    String imageName = "$dockerRegistry/k8s-sec-3-things:${versionName}"

    docker.withRegistry("https://$dockerRegistry", 'gcloud-docker') {
        docker.build(imageName, '.').push()
    }

    withCredentials([file(credentialsId: 'kubeconfig-bc-production', variable: 'kubeconfig')]) {

        withEnv(["IMAGE_NAME=$imageName"]) {

            kubernetesDeploy(
                    credentialsType: 'KubeConfig',
                    kubeConfig: [path: kubeconfig],

                    configs: 'k8s.yaml',
                    enableConfigSubstitution: true
            )
        }
    }
}
