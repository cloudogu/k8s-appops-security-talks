<!-- .slide: data-background-image="images/subtitle.jpg"  -->
# 3. Security Context



> Defines privilege and access control settings for a Pod or Container

🌐 https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

See also: Secure Pods - Tim Allclair  
🎥 https://www.youtube.com/watch?v=GLwmJh-j3rs



## Recommendation per Container 

```yaml
apiVersion: v1
kind: Pod
# ...
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
```
There is also a securityContext on pod level, but not all of those settings cannot be applied there.



### Recommendation per Container in Detail (1)
 
* `allowPrivilegeEscalation: false`
  * mitigates a process within the container from gaining higher privileges than its parent (the container process)
  * E.g. `sudo`, `setuid`, Kernel vulnerabilities
* `seccomp.security.alpha.kubernetes.io/pod: runtime/default` 
  * Enables e.g. docker's seccomp default profile that block 44/~300 Syscalls 
  * Has mitigated some Kernel vulns in the past and might in the future 🔮:  
    🌐 https://docs.docker.com/engine/security/non-events/
  * no seccomp profile is also one of the findings of the k8s security audit:  
    🌐 https://www.cncf.io/blog/2019/08/06/open-sourcing-the-kubernetes-security-audit/
* `"capabilities":  { "drop": [ "ALL" ] }`  
  * Reduces attack surface
  * Drops even the default caps:  
    🌐 https://github.com/moby/moby/blob/master/oci/defaults.go#L14-L30

Notes:
* seccomp
  * Switching off in docker would be security misconfiguration. In K8s it's [explicitly deactivated](https://github.com/kubernetes/kubernetes/issues/20870) :-o
  But [will be activated in one of the next versions](https://github.com/kubernetes/enhancements/issues/135)
  * Has been thoroughly tested by docker on all Dockerfiles on GitHub - see [Jessica Frazzelle](https://blog.jessfraz.com/post/containers-security-and-echo-chambers/)



### Recommendation per Container in Detail (2)

* `runAsNonRoot: true` - Container is not started when the user is root
* `runAsUser` and `runAsGroup` > 10000  
  * Reduces risk to run as user existing on host 
  * In case of container escape UID/GID does not have privileges on host/filesystem 
* `readOnlyRootFilesystem: true` 
  * Mounts the whole file system in the container read-only. Writing only allowed in volumes.
  * Makes sure that config or code within the container cannot be manipulated.
  * It's also more efficient (no CoW).
  
Notes:
* `runAsNonRoot` for nginx image: `Error: container has runAsNonRoot and image will run as root`
    * For custom images: Best Practice run as USER
    * For OTS images this might not be possible
    * For NGINX you could build your own image that does not run as root




## 🚧️ Security context pitfalls

* `readOnlyRootFilesystem` - most applications need temp folders to write to
  * Run image locally using docker, access app (<i class='fas fa-thumbtack'></i> run automated e2e/integration tests)
  * Then use `docker diff` to see a diff between container layer and image
  * and mount all folders listed there as `emptyDir` volumes in your pod
* `capabilities` - some images require capabilities
  * Start container locally with docker and `--cap-drop ALL`, then check logs for errors
  * Start again add caps as needed with e.g. `--cap-add CAP_CHOWN`, check logs for errors
  * Start again with additional caps and so forth.
  * Add all necessary caps to k8s resource
  * Alternative: Find an image of same app that does not require caps, e.g. `nginxinc/nginx-unprivileged`  
* `runAsGroup` - beta from K8s 1.14. Before that defaults to GID 0 ☹  
   🌐 https://github.com/kubernetes/enhancements/issues/213

Note:
* `runAsGroup` was alpha from 1.10, which is deactivated by default



## 🚧️ Security context pitfalls - `runAsNonRoot`

*  Non-root verification only supports numeric user. 🙄  
 * `runAsUser: 100000` in `securityContext` of pod or 
 * `USER 100000` in `Dockerfile` of image.
* Some official images run as root by default.  
  * Find a **trusted** image that does not run as root  
    e.g. for nginx, or postgres: <i class='fab fa-docker'></i> https://hub.docker.com/r/bitnami/
  * Derive from the original image and create your own non-root image  
    e.g. nginx: <i class='fab fa-github'></i> https://github.com/schnatterer/nginx-unpriv
* UID 100000 might not have permissions to read/write. Possible solutions:
  * Init Container sets permissions for PVCs
  * Wrong permissions in container ➜ `chmod`/`chown` in `Dockerfile` 
* Some applications require a user for UID in `/etc/passwd`  
  * New image that contains a user for UID e.g. `100000` or
  * Create `/etc/passwd` with user in init container and mount into application container



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



## 🐐 Demo

<img data-src="images/demo-sec-ctx.svg" width=35% />

Note: 
* [Demo Script](/demo/3-security-context/Readme.md)
* [plantUml src](http://www.plantuml.com/plantuml/uml/dP0nQyD038Nt-nN2XMOofGs4ZA65Z2MGiNGG9zKSjYKZw-gKal_Ui_6GhBr9z-xfVOyxZ8xckU_2s2OPqB279CxsXP7XDm2yOcmRqopqffqQFBniSKiqlwWHswe-xtRxFOLhk0b2CvsMaBlLUrFKVb1XyN_G08uglch7vSpXGPGOgZF7RCb_2bsSBmwFS3gVgi8fYqC1OLDSxzZpM6uCcobrL4yy-gQ2fGt0XpH9BfytSvBuj0nrbi7IT-guOLeTfB5bgyTCEYlNKEeSMAXyy1y0)



## 🎁 Wrap-Up: Security Context

My recommendations

* Security Context
  * Start with least privilege
  * Only differ if there's absolutely no other way
* BTW - you can enforce Security Context Settings by using Pod Security Policies.  
  However, those cause a lot more effort to maintain.