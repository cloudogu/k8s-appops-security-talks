# Summary

IMHO ever person working with k8s should *at least* adhere to the following:

* Enable RBAC!
* Don't allow arbitrary connection between pods.   
  (e.g use Network Policies to whitelist ingresses)
* Don't allow privilege escalation via the security context of each container
* Try to run your containers 
 * as non-root user and
 * with a read-only file system.



<!-- .slide: data-background-image="images/title.svg"  -->
 
### Johannes Schnatterer

*Cloudogu GmbH*

🌐  https://cloudogu.com/schulungen

🌐  https://cloudogu.com/blog


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