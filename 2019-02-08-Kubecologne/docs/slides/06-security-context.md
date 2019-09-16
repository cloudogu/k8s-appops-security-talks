# 3. Security Context

> Defines privilege and access control settings for a Pod or Container

🌐 https://kubernetes.io/docs/tasks/configure-pod-container/security-context/



## Recommendation per Container 

* `allowPrivilegeEscalation: false`
  * mitigates a process within the container from gaining higher privileges than its parent (the container process)
  * E.g. `sudo`, `setuid`, Kernel vulnerabilities
* `runAsNonRoot` - Container is not started when the user is root
* `readOnlyRootFilesystem: true` 
  * Mounts the whole file system in the container read-only. Writing only allowed in volumes.
  * Makes sure that config or code within the container cannot be manipulated.
  * It's also more efficient (no CoW).

Notes:
* Additional properties secure by default  
  🌐 https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#securitycontext-v1-core
    * `privileged` - Access all devices of the host. Default false. 



```yaml
apiVersion: v1
kind: Pod
#...
spec:
  containers:
  - name: cntnr
    securityContext:
      runAsNonRoot: true
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
```
There is also a `securityContext` on pod level, but those settings cannot be applied there.



## 🚧️ Security context pitfalls

* `readOnlyRootFilesystem` - most applications need temp folders to write to
  * Run image locally using docker, access app (<i class='fas fa-thumbtack'></i> run automated e2e/integration tests)
  * Then use `docker diff` to see a diff between container layer and image
  * and mount all folders listed there as `emptyDir` volumes in your pod
* `runAsNonRoot` 
  *  Non-root verification only supports numeric user. 🙄  
     Either set e.g. 
     * `runAsUser: 1000` in `securityContext` of pod or 
     * `USER 1000` in `Dockerfile` of image.
  * Some official images run as root by default.  
    Possible solutions:
      * Find a **trusted** image that does not run as root  
        e.g. for nginx, or postgres: <i class='fab fa-docker'></i> https://hub.docker.com/r/bitnami/
      * Derive from the original image and create your own non-root image  
        e.g. nginx: <i class='fab fa-github'></i> https://github.com/schnatterer/nginx-unpriv



## 🐐 Demo

<img data-src="images/demo-sec-ctx.svg" width=35% />

Note: 
* [plantUml src](http://www.plantuml.com/plantuml/uml/dP2nQWCn38PtFuMuGZE5qWP2nj12nXB8M3gebdgOEqk7hEDIIjwzlZH3iaQJ_Vdt_u6snT5yp7qeNP813JCaSRPlZ0o_0U0LOzUQZa9lsgl1myiALqJpYngnNUZpUhtPK3Y5go8qq-bSSllr9XGr3oeiVeSDOAVY5xOxprmUH8cXEN0SBVbFjOlpqU4HzeTzKpq1OAWYR6lg7JENUcDOJAcdvSJ55mtK5DJva3R9yVF__9LSCAUdQqOQExPb6KbdKksdi6MXkj8_)



## 🎁 Wrap-Up: Security Context

My recommendations

* Security Context
  * Start with `readOnlyRootFilesystem`, `runAsNonRoot` and `allowPrivilegeEscalation: false`
  * Only differ if there's absolutely no other way
* BTW - you can enforce Security Context Settings by using Pod Security Policies.  
  However, those cause a lot more effort to maintain.