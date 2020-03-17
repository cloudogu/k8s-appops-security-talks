<!-- .slide: data-background-image="images/subtitle.jpg"  -->
# Pod Security Policies <br/>(PSP) 



* enforces security context cluster-wide   
* additional options enforcing secure defaults
* more effort than security context and different syntax  🙄 
  
➡️ Still highly recommended!



## Recommendations

* Same as Security Context 
* Plus: Enforce secure defaults.  
  Block pods from 
    * entering node's Linux namespaces, e.g. net, PID   
      (includes binding ports to nodes directly),
    * mounting arbitrary host paths (from node)  
      (includes docker socket), 
    * starting `privileged` containers,
    * changing apparmor profile

Note:
* By default: All of this is possible when deploying pods!
* Example for host paths exploits:
  * https://blog.aquasec.com/kubernetes-security-pod-escape-log-mounts
  * https://blog.aquasec.com/kubernetes-security-pod-escape-log-mounts 



## SecCtx recommendations➡️PSP

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    seccomp.security.alpha.kubernetes.io/defaultProfileName: runtime/default
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: runtime/default
spec:
  requiredDropCapabilities:
    - ALL
  allowedCapabilities: []
  defaultAllowPrivilegeEscalation: false
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  runAsUser: # Same for runAsGroup, supplementalGroups, fsGroup
    rule: MustRunAs
    ranges:
      - min: 100000
        max: 999999
```

Note:
* Same as securityContext, except syntax.
* Behavior of options is not always intuitive
* If no `allowedProfileNames` startup will fail, because `defaultProfileName` is not allowed.
* `requiredDropCapabilities` drop even default ones. `allowedCapabilities` fails container start if caps are added explicitly. 
* `defaultAllowPrivilegeEscalation` changes default. `allowPrivilegeEscalation` fails container start if value is changed explicitly. 
* `readOnlyRootFilesystem` only one value: Default that cannot be changed.
* `runAsUser`, etc. Sets `min` by default. Fails container start if value is > `max` in securityContext.



## Additional Recommendations

<!-- .slide: style="font-size: 30px"  -->
```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
    apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
spec:
  hostIPC: false
  hostPID: false
  hostNetwork: false
  hostPorts: []
  privileged: false
  allowedHostPaths: []
  volumes:
    - configMap
    - emptyDir
    - projected
    - secret
    - downwardAPI
    - persistentVolumeClaim
```

Note:
* `apparmor...` fails container start if value is changed explicitly. 
* `hostX` No more  entering node's Linux namespaces for pods. `hostPorts` is only possible if in `hostNetwork` (redundant but more secure)
* `privileged`: fails container start if value is changed explicitly. 
* `allowedHostPaths` and `volumes` - blocks mounting arbitrary host paths (`/var/run/docker.sock`)
  Core type must be allowed explicitly.



## Usage

1. Activate Admission controler via API-Server  
   (also necessary for most managed k8s)  
2. Define PSP (YAML)
3. Activate via RBAC

Example:   
<i class='fab fa-github'></i> https://github.com/cloudogu/k8s-security-demos/blob/master/4-pod-security-policies/demo/01-psp-restrictive.yaml



## Activation via RBAC

<img data-src="images/psp-rbac.svg" />

Note:
* [plantUml src](https://www.plantuml.com/plantuml/uml/dL1DYzim4BtxLwZR7jg3OxfBbn2MPRk1d4DpxMKaJMrXMH8pKaDQ-jyxLa98avvsC1Y_ZyTxVk4CbClactSk65yi5l9go3dngki8zelUvQ7emaWcXemXBqoSkicPmQ7laeSmszknQAI06RdbH4xUtGISaJf2ZeKCTkFopBKbUD3eqRRtNvB92pTNQ7Xq8G71f5mGwmymg7utIhs26NkA9TXrz97K-_i7UB1sPY9Pf1Fw-V5nkRJDdyiW88hx6d9jtSYS4xQfzwzHLgOOPEyR6lm_N4vTnDuzVKYSdh-7RRGxD8LSFcoZT-Pmfu2LSDToYXv5_t7jo_ndsq_V1AZYcRbHwnljgmlMXVveqTS61Z7ia7uwWr-DaR6vAXbkUaTxx5rv-HA1F59PFRMrp4f1oKCazmjLOUbMqShgbTBIOuQqQfyb_WmmY6BE4pkpwqFpWi6MoVy5)



## 🚧️ Security context pitfalls

* <font color="red">⚠</font> *Admission*Controller
  * only evaluates Pods before starting
  * if not active ➡️ PSP are ignored
  * if active but no PSP defined ➡️ *no* pod can be started 
* Different PSP API group in `(Cluster)Role`
  * < 1.16: `apiGroups [ extensions ]` 
  * ≥ 1.16: `apiGroups [ policy ]`
* Loose coupling in RBAC ➡️ fail late with typos

Note:
* apiGroups
  * `policy` seems not to work in > 1.16
  * `extensions` seems not to work in ≥ 1.16

More Pitfalls:
* Multiple PSPs: 1st one to allow is picked
  🌐 https://kubernetes.io/docs/concepts/policy/pod-security-policy/#policy-order
* `seLinux` setting in PSP ins mandatory, even if no SELinux is used



### <i class='fas fa-thumbtack'></i>  PSP Debugging Hints
<!-- .slide: style="font-size: 30px"  -->

```bash
# Query active PSP
kubectl get pod <POD> -o jsonpath='{.metadata.annotations.kubernetes\.io/psp}'  
# Check authorization
kubectl auth can-i use psp/privileged --as=system:serviceaccount:<NS>:<SA>
# Show which SA's are authorized (kubectl plugin)
kubectl who-can use psp/<PSP>
# Show roles of a SA (kubectl plugin)
kubectl rbac-lookup <SA> # e.g. subject = sa name 
```



## PSP Limitations

* Unavailable options in PSPs
    * `enableServiceLinks: false` 
    * `automountServiceAccountToken: false`
* Future of PSPs uncertain  
  <i class='fab fa-github'></i> https://github.com/kubernetes/enhancements/issues/5  
  ➡️ Still easiest way for cluster-wide least privilege

Note:
* Unavailable: Alternatives
   * Security Context per Pod
   * Write Mutating Webhook
* Furore of PSP
    * PSP still Beta (1.18) - GA not certain (Jun 19, 2019)
    * Alternatives: (Jun 19, 2019)
        * PSP as out of tree admission Webhook /
        * OPA potential alternative ("doesn't have the features (or stability)...yet") 
    * Deprecation only with "clear replacement"



## 🗣️ Demo

<img data-src="images/demo-psp.svg" width=35% />

Note: 
* [Demo Script](https://github.com/cloudogu/k8s-security-demos/blob/master/4-pod-security-policies/Readme.md)
* [plantUml src](http://www.plantuml.com/plantuml/uml/dP11IyCm5CVl_HJFAkpK1JSSHMGC1xi8Ve6vGvOysz3q9RmaJf1zTzDIT3juCOSsxxtV_vUccn0bnzJRuiQGiabZOWjjZ3uy2i7oD6zCRDCn1MJbA2B5kNAzw8rg3LhXhQGXNdNfY4mOCLJ1iyblqSiGaGLZS8aLYgx-cLM9h3oYHLqj7hoASpDyGX4wGrwoxC5GZhvBXV1L03nBrJNi4kcjiuxXTh6KIws7YMEDF7NlLwkwriNvKYIPtMcKN4Ule7mZxmWf_kCqW9sZEFLsunha1JcDKBxK0ROs3J-YpF9C-soNJHwzoXv3hX1cFlXP2J80XGn1Ndjg37qQKcBSL8aycmzZiK5zk226VJuDBgvGFjrbt_gDybFyfaR_KFuDCuR8HiK97ii2Ca-XshT6QwH3jPuaryq9FXSR99rw-mq0)