<!-- .slide: data-background-image="images/subtitle.jpg"  -->
# 2. Security Context



Defines security parameter per pod/container ➜ container runtime  

<i class='fas fa-thumbtack'></i> Secure Pods - Tim Allclair  
🎥 https://www.youtube.com/watch?v=GLwmJh-j3rs



## Recommendations per Container 

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations: 
    seccomp.security.alpha.kubernetes.io/pod: runtime/default
spec:
  containers:
  - name: restricted
    securityContext:
      runAsNonRoot: true
      runAsUser: 100000
      runAsGroup: 100000
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      capabilities:
        drop:
          - ALL
  enableServiceLinks: false
```

Note:
There is also a securityContext on pod level, but not all of those settings cannot be applied there.



## Recommendation per Container in Detail




### Enable seccomp
 
* Enables e.g. docker's seccomp default profile that block 44/~300 Syscalls 
* Has mitigated Kernel vulns in past and might in future 🔮   
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
  * Reduces risk to run as user existing on host 
  * In case of container escape UID/GID does not have privileges on host
* Mitigates vuln in `runc` (used by Docker among others)  
  🌐 https://kubernetes.io/blog/2019/02/11/runc-and-cve-2019-5736/

Notes:
* `runAsNonRoot` for nginx image: `Error: container has runAsNonRoot and image will run as root`
    * For custom images: Best Practice run as USER
    * For OTS images this might not be possible
    * For NGINX you could build your own image that does not run as root



### No Privilege escalation

* Container can't increase privileges
* E.g. `sudo`, `setuid`, Kernel vulnerabilities



### Read-only root file system

* Starts container without read-write layer 
* Writing only allowed in volumes
* Config or code within the container cannot be manipulated
* Perk: More efficient (no CoW)



### Drop Capabilities
  
* Drops even the default caps:  
  🌐 https://github.com/moby/moby/blob/3152f94/oci/caps/defaults.go
* Mitigates `CapNetRaw` attack - DNS Spoofing on Kubernetes Clusters  
  🌐 https://blog.aquasec.com/dns-spoofing-kubernetes-clusters



### Bonus: No Services in Environment

* By default: Each K8s service written to each container's env vars  
  ➜ Docker Link legacy, no longer needed
* But convenient info for attacker where to go next



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
* Add necessary caps to k8s resource
* Alternative: Find image with same app that does not require caps, e.g. `nginxinc/nginx-unprivileged`  



### Run as unprivileged user

*  Non-root verification only supports numeric user. 🙄  
 * `runAsUser: 100000` in `securityContext` of pod or 
 * `USER 100000` in `Dockerfile` of image.
* Some official images run as root by default.  
  * Find a **trusted** image that does not run as root  
    e.g. for mongo or postgres:   
    <i class='fab fa-docker'></i> https://hub.docker.com/r/bitnami/
  * Derive from the original image and create your own non-root image  
    e.g. nginx: <i class='fab fa-github'></i> https://github.com/schnatterer/nginx-unpriv



* UID 100000 might not have permissions. Solutions:
  * Init Container sets permissions for PVCs
  * Permissions in image ➜ `chmod`/`chown` in `Dockerfile` 
* Application requires user for UID in `/etc/passwd`  
  * New image that contains a user for UID e.g. `100000` or
  * Create `/etc/passwd` in init container and mount into app container
* `runAsGroup` - beta from K8s 1.14. Before that defaults to GID 0 ☹  
   🌐 https://github.com/kubernetes/enhancements/issues/213
  
Note:
* `runAsGroup` was alpha from 1.10, which is deactivated by default



## Tools

Find out if your cluster adheres to these and other good security practices:  

* <i class='fab fa-github'></i> [controlplaneio/kubesec](https://github.com/controlplaneio/kubesec) - managable amount of checks
* <i class='fab fa-github'></i> [Shopify/kubeaudit](https://github.com/Shopify/kubeaudit) 
  * a whole lot of checks,
  * even deny all ingress and egress NetPols and AppArmor Annotations

➜ Be prepared for a lot of findings  
➜ Create your own good practices

Note:
➜ Results differ between tools.   
➜ The checks are opinionated, just like the recommendations show here.  
➜ Scrutinize, prioritize and be pragmatic when fixing.



## 🗣️ Demo

<img data-src="images/demo-sec-ctx.svg" width=35% />

Note: 
* [Demo Script](/demo/3-security-context/Readme.md)
* [plantUml src](http://www.plantuml.com/plantuml/uml/dP0nQyD038Nt-nN2XMOofGs4ZA65Z2MGiNGG9zKSjYKZw-gKal_Ui_6GhBr9z-xfVOyxZ8xckU_2s2OPqB279CxsXP7XDm2yOcmRqopqffqQFBniSKiqlwWHswe-xtRxFOLhk0b2CvsMaBlLUrFKVb1XyN_G08uglch7vSpXGPGOgZF7RCb_2bsSBmwFS3gVgi8fYqC1OLDSxzZpM6uCcobrL4yy-gQ2fGt0XpH9BfytSvBuj0nrbi7IT-guOLeTfB5bgyTCEYlNKEeSMAXyy1y0)



## 🎁 Wrap-Up: Security Context

My recommendations:

* Start with least privilege
* Only differ if there's absolutely no other way


Note:
BTW - Security Context settings can be enforced cluster-wide via Pod Security Policies  