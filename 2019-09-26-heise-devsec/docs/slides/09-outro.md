# Summary

IMHO ever person working with k8s should *at least* adhere to the following:

* Enable RBAC!
* Don't allow arbitrary connection between pods.   
  (e.g. use Network Policies to whitelist ingresses)
* Start with least privilege for your containers:
    * Block privilege escalation via the security context of each container
    * Enable the seccomp default module via annotation of each pod
    * Try to run your containers 
      * as non-root user, with UID & GID >= 10000,  
      * with a read-only file system and
      * without capabilities.
* Least privilege rules can either be set per container (securityContext) or cluster-wide (PodSecurityPolicy) 



<!-- .slide: data-background-image="images/title.svg"  -->
 
### Johannes Schnatterer

*Cloudogu GmbH*

🌐  https://cloudogu.com/schulungen

<br/>
K8s Security series on JavaSPEKTRUM starting 05/2019

See also 🌐  https://cloudogu.com/blog

<a href='https://twitter.com/jschnatterer' class="social" target="_blank">
    <i class='fab fa-twitter'></i>
    @jschnatterer
</a>

<a href='https://twitter.com/cloudogu' class="social" target="_blank">
    <i class='fab fa-twitter'></i>
    @cloudogu
</a>

<br/>
Demo Source: 
<a href='https://github.com/cloudogu/k8s-security-demos' class="social" target="_blank">
    <i class='fab fa-github'></i>
    https://github.com/cloudogu/k8s-security-demos
</a>

Note: 
* JavaSPEKTRUM [05/2019: (27.09.2019)](https://www.sigs-datacom.de/fachzeitschriften/javaspektrum.html)