<!-- .slide: data-background-image="images/subtitle.jpg"  -->
# Security Context



* Security Context: Defines security parameters *per pod/container*  
   ➡️ container runtime
* ↔️ Cluster-wide security parameters: See Pod Security Policies  





## Recommendations per Container 

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations: 
    seccomp.security.alpha.kubernetes.io/pod: runtime/default # k8s <= 1.18
spec:
  containers:
  - name: restricted
    securityContext:
      runAsNonRoot: true
      runAsUser: 100000
      runAsGroup: 100000
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      seccompProfile: # k8s >= 1.19
        type: RuntimeDefault
      capabilities:
        drop:
          - ALL
  enableServiceLinks: false
  automountServiceAccountToken: false # When not communicating with API Server  
```

Note:
There is also a securityContext on pod level, but not all of those settings cannot be applied there.



## Recommendation per Container in Detail




### Enable seccomp
 
* Enables e.g. docker's seccomp default profile that block 44/~300 Syscalls 
* 🔥 Has mitigated Kernel vulns in past and might in future 🔮   
  🌐 https://docs.docker.com/engine/security/non-events/
* See also k8s security audit:  
  🌐 https://www.cncf.io/blog/2019/08/06/open-sourcing-the-kubernetes-security-audit/

Notes:
* seccomp
  * Switching off in docker would be security misconfiguration. In K8s it's [explicitly deactivated](https://github.com/kubernetes/kubernetes/issues/20870) :-o
  But [will be activated in one of the next versions](https://github.com/kubernetes/enhancements/issues/135)
  * Has been thoroughly tested by docker on all Dockerfiles on GitHub - see [Jessica Frazzelle](https://blog.jessfraz.com/post/containers-security-and-echo-chambers/)



### Run as unprivileged user

* `runAsNonRoot: true`   
   Container is not started when the user is root
* `runAsUser` and `runAsGroup` > 10000  
  * 🔥 Reduces risk to run as user existing on host 
  * 🔥 In case of container escape UID/GID does not have privileges on host
* 🔥 E.g. mitigates vuln in `runc` (used by Docker among others)  
  🌐 https://kubernetes.io/blog/2019/02/11/runc-and-cve-2019-5736/

Notes:
* `runAsNonRoot` for nginx image: `Error: container has runAsNonRoot and image will run as root`
    * For custom images: Best Practice run as USER
    * For OTS images this might not be possible
    * For NGINX you could build your own image that does not run as root



### No Privilege escalation

<img data-src="images/sandwich.png" width=30% class="floatRight"/>

* Container can't increase privileges
* 🔥 E.g. `sudo`, `setuid`, Kernel vulnerabilities
<br/>
<br/>
<br/>
<font size="1" style="text-align: right;" class="floatRight">🌐 https://xkcd.com/149/</font>



### Read-only root file system

* Starts container without read-write layer 
* Writing only allowed in volumes
* 🔥 Config or code within the container cannot be manipulated



### Drop Capabilities
  
* Drops even the default caps:  
  🌐 https://github.com/moby/moby/blob/3152f94/oci/caps/defaults.go
* 🔥 E.g. Mitigates `CapNetRaw` attack - DNS Spoofing on Kubernetes Clusters  
  🌐 https://blog.aquasec.com/dns-spoofing-kubernetes-clusters



### Bonus: No Services in Environment

* By default: Each K8s service written to each container's env vars  
  ➡️ Docker Link legacy, no longer needed
* 🔥 But convenient info for attacker where to go next

Note:
Can also cause unpredictable errors: e.g. 
* service `POSTGRES` -> env `POSTGRES_PORT` mounted into every port in Namespace.
* Is picked up by e.g. [keycloak](https://github.com/keycloak/keycloak-containers/blob/master/server/README.md) container.
  Even it not planned!
  Another example - docker/registry?
  



### Bonus: Disable access to K8s API

* SA Token in every pod for api-server authn 
```bash
curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  https://${KUBERNETES_SERVICE_HOST}/api/v1/
```
* If not needed, disable!
* No authentication possible
* 🔥 Lesser risk of security misconfig or vulns in authz  
  <!-- These blanks disable the horizontal scroll bar in the listing above :-( -->
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;



## 🚧️ Security context pitfalls



### Read-only root file system

Application might need temp folder to write to

* Run image locally using docker, access app  
  <i class='fas fa-thumbtack'></i> Run automated e2e/integration tests
* Review container's read-write layer via

```bash
docker diff <containerName>
```

* Mount folders as `emptyDir` volumes in pod



### Drop Capabilities

Some images require capabilities

* Find out needed Caps locally:

```bash
docker run --rm --cap-drop ALL <image>
# Check error
docker run --rm --cap-drop ALL --cap-add CAP_CHOWN <image>
# Keep adding caps until no more error
```
* Add necessary caps to k8s `securityContext`
* Alternative: Find image with same app that does not require caps, e.g. `nginxinc/nginx-unprivileged`  



### Run as unprivileged user

* Some official images run as root by default.  
  * Find a **trusted** image that does not run as root  
    e.g. for mongo or postgres:   
    <i class='fab fa-docker'></i> https://hub.docker.com/r/bitnami/
  * Create your own non-root image  
    (potentially basing on original image)  
    e.g. nginx: <i class='fab fa-github'></i> https://github.com/schnatterer/nginx-unpriv



* UID 100000 lacks file permissions. Solutions:
  * Init Container sets permissions for volume
  * Permissions in image ➡️ `chmod`/`chown` in `Dockerfile` 
  * Run in root Group - `GID 0`  
    🌐 https://docs.openshift.com/container-platform/4.3/openshift_images/create-images.html#images-create-guide-openshift_create-images

Note:
Some more (less likely to happen these days)
* `runAsGroup` was alpha from 1.10, which is deactivated by default
* Application requires user for UID in `/etc/passwd`  
  * New image that contains a user for UID e.g. `100000` or
  * Create `/etc/passwd` in init container and mount into app container
* `runAsGroup` - beta from K8s 1.14. Before defaults to GID 0 ☹  
   🌐 https://github.com/kubernetes/enhancements/issues/213



## 🗣️ Demo

<img data-src="images/demo-sec-ctx.svg" width=35% />

Note: 
* [Demo Script](https://github.com/cloudogu/k8s-security-demos/blob/master/3-security-context/Readme.md)
* [plantUml src](https://www.plantuml.com/plantuml/uml/dP2nQiD038RtUmhX3fbCQGF1OsWWIw4lK3g8aseEsvBHtRM1adUlR3maQpJfVdtt2NJC1QtKQGnvI3AZuGH92jitHeQ_0F26SUXDgz19HpLuUjtZdcYPg17RbhuS3br7uHfkH6Yclwla_kiT57MQLLZA0zi0pYfboyvhBV8WIWpDUvVXDDPSs1gNEpsx7NiVVU34sLyCkyonZUMoQy0PyFgKFidbwwPF4f_NfgqoM_f98_TC6q4Q1xOsLz8byVNNS6GXl-a_)



## 🎁 Wrap-Up: Security Context

My recommendations:

* Start with least privilege
* Only differ if there's absolutely no other way


Note:
BTW - Security Context settings can be enforced cluster-wide via Pod Security Policies  
