#!groovy

@Library('github.com/cloudogu/ces-build-lib@1.44.3')
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

    String conferenceName = '2020-10-23-heise-devsec'
    pdfBaseName = 'Secure-by-Default-Pragmatically-Improve-App-Security-Using-K8s-Built-Ins'
    String imageBaseName = 'cloudogu/k8s-appops-security-talks'
    
    def introSlidePath = 'docs/slides/00-title.md'
    headlessChromeVersion = 'yukinying/chrome-headless-browser:87.0.4280.11'

    Git git = new Git(this, 'cesmarvin')
    git.committerName = 'cesmarvin'
    git.committerEmail = 'cesmarvin@cloudogu.com'
    
    catchError {

        stage('Checkout') {
            checkout scm
            git.clean('')
        }

        String pdfName = createPdfName()

        String versionName = "${new Date().format('yyyyMMddHHmm')}-${git.commitHashShort}"
        String imageName = "${imageBaseName}:${versionName}"
        String packagePath = 'dist'
        def image
        
        stage('Build') {
            writeVersionNameToIntroSlide(versionName, introSlidePath)
            image = docker.build imageName
        }

        stage('Print PDF & Package WebApp') {
            String pdfPath = "${packagePath}/${pdfName}"
            printPdfAndPackageWebapp image, pdfName, packagePath
            archiveArtifacts pdfPath
            // Use a constant name for the PDF for easier URLs, for deploying
            sh "mv '${pdfPath}' '${packagePath}/${createPdfName(false)}'"
            // Build image again, so PDF is added
            image = docker.build imageName
        }

        stage('Deploy GH Pages') {
            
            if (env.BRANCH_NAME == 'master') {
                git.pushGitHubPagesBranch(packagePath, versionName, conferenceName)
            } else {
                echo "Skipping deploy to GH pages, because not on master branch"
            }
        }
    }

    mailIfStatusChanged(git.commitAuthorEmail)
}

String pdfBaseName
String headlessChromeVersion

String createPdfName(boolean includeDate = true) {
    String title = pdfBaseName
    if (!title) {
        title = sh (returnStdout: true, script: "grep -r '<title>' index.html | sed 's/.*<title>\\(.*\\)<.*/\\1/'").trim()
    }
    String pdfName = '';
    if (includeDate) {
        pdfName = "${new Date().format('yyyy-MM-dd')}-"
    }
    pdfName += "${title}.pdf"
    return pdfName
}

void writeVersionNameToIntroSlide(String versionName, String introSlidePath) {
    String filteredIntro = filterFile(introSlidePath, "<!--VERSION-->", "Version: $versionName")
    sh "cp ${filteredIntro} ${introSlidePath}"
    sh "mv ${filteredIntro} ${introSlidePath}"
}

void printPdfAndPackageWebapp(def image, String pdfName, String distPath) {
    Docker docker = new Docker(this)

    image.withRun("-v ${WORKSPACE}:/workspace -w /workspace") { revealContainer ->

        // Extract rendered reveal webapp from container for further processing
        sh "docker cp ${revealContainer.id}:/reveal '${distPath}'"
        
        def revealIp = docker.findIp(revealContainer)
        if (!revealIp || !waitForWebserver("http://${revealIp}:8080")) {
            echo "Warning: Couldn't deploy reveal presentation for PDF printing. "
            echo "Docker log:"
            echo new Sh(this).returnStdOut("docker logs ${revealContainer.id}")
            error "PDF creation failed"
        }

        docker.image(headlessChromeVersion)
        // Chromium writes to $HOME/local, so we need an entry in /etc/pwd for the current user
                .mountJenkinsUser()
        // Try to avoid OOM for larger presentations by setting larger shared memory
                .inside("--shm-size=2G") {
                    // If more flags should ever be neccessary: https://peter.sh/experiments/chromium-command-line-switches
                    sh "/usr/bin/google-chrome-unstable --headless --no-sandbox --disable-gpu --print-to-pdf='${distPath}/${pdfName}' " +
                            "http://${revealIp}:8080/?print-pdf"
                }
    }
}

/**
 * Filters a {@code filePath}, replacing an {@code expression} by {@code replace} writing to new file, whose path is returned.
 *
 * @return path to filtered file
 */
String filterFile(String filePath, String expression, String replace) {
    String filteredFilePath = filePath + ".filtered"
    // Fail command (and build) if file not present
    sh "test -e ${filePath} || (echo Title slide ${filePath} not found && return 1)"
    sh "cat ${filePath} | sed 's/${expression}/${replace}/g' > ${filteredFilePath}"
    return filteredFilePath
}

boolean waitForWebserver(String url) {
    echo "Waiting for website to become ready at ${url}"
    // Output to stdout and discard (O- >/dev/null) because we don't want the file we only want to know if it's available
    int ret = sh (returnStatus: true, script: "wget O- --retry-connrefused --tries=30 -q --wait=1 ${url} &> /dev/null")
    return ret == 0
}