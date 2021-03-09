<!-- .slide: data-background-image="images/subtitle.jpg"  -->
# Pod Security Policies <br/>(PSP) 



* enforces security context settings cluster-wide 
* additional options enforcing secure defaults
* But:

> PSPs will be deprecated in 1.21 with removal targeted for 1.25.  
 <i class='fab fa-github'></i> https://github.com/kubernetes/enhancements/issues/5



## PSP Deprecated - what now?

* Deploy external tools
  * <i class='fab fa-github'></i> https://github.com/open-policy-agent/opa/  
     versatile, CNCF Graduated  
     e.g. PSP via OPA 🌐 https://www.infracloud.io/blogs/kubernetes-pod-security-policies-opa/
  * <i class='fab fa-github'></i> https://github.com/kyverno/kyverno/  
    lightweight, CNCF Sandbox
* Use PSP anyway
  * 🎥 https://youtu.be/YlvdFE1RsmI?t=3092 🇩🇪 including Demo
  * 🌐 https://cloudogu.com/en/blog/k8s-app-ops-part-5-pod-security-policies-1 🇬🇧 🇩🇪