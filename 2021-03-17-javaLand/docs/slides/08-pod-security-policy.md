<!-- .slide: data-background-image="images/subtitle.jpg"  -->
# Pod Security Policies <br/>(PSP) 



* enforces security context settings cluster-wide 
* additional options enforcing secure defaults
* But:

> PSPs will be deprecated in 1.21 with removal targeted for 1.25.  
 <i class='fab fa-github'></i> https://github.com/kubernetes/enhancements/issues/5

Note: 
k8s 1.21 2021-08-04
https://www.kubernetes.dev/resources/release/



## PSP Deprecated - what now?

* Deploy external tools
  * <i class='fab fa-github'></i> https://github.com/open-policy-agent/opa/  
  * <i class='fab fa-github'></i> https://github.com/kyverno/kyverno/  
* Wait for PSP replacement. WIP!   
  <i class="fab fa-google-drive"></i> https://docs.google.com/document/d/1dpfDF3Dk4HhbQe74AyCpzUYMjp4ZhiEgGXSMpVWLlqQ
* Use PSP anyway, migrate in K8s 1.25. Hopefully.
  * 🎥 https://youtu.be/YlvdFE1RsmI?t=3092 🇩🇪 including Demo
  * 🌐 https://cloudogu.com/en/blog/k8s-app-ops-part-5-pod-security-policies-1 🇬🇧 🇩🇪

Note:
* Deploy external tools
    * OPA: versatile, CNCF Graduated  
         e.g. [PSP via OPA](https://www.infracloud.io/blogs/kubernetes-pod-security-policies-opa/)
    * Kyverno: lightweight, CNCF Sandbox
* Replacement:
  * Implements [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
  * Activated via labels on namespaces  
  * Policy Types: privileged (unrestricted), baseline (minimally restrictive; default), restricted (hardening best practice)
  * Will be versioned (e.g. pod security policy k8s 1.7 had no privilege escalation flag. Breaking change in 1.8!)