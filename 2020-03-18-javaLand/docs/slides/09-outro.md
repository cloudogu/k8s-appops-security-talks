# Summary

* Enable RBAC
* Don't allow arbitrary connections between pods, e.g. via NetPols   
* Start with least privilege for your containers
  * using either securityContext or
  * PodSecurityPolicy 



## What for?

* Increase security <!-- .element: class="fragment"  -->
* Reduce risk of data breach <!-- .element: class="fragment"  -->
<li class="fragment"> Don't end up on  <a href='https://twitter.com/haveibeenpwned' class="social" target="_blank"><i class='fab fa-twitter'></i>@haveibeenpwned</a> </li>  





<!-- .slide: data-background-image="images/title.svg"-->

### Johannes Schnatterer

Cloudogu GmbH

🌐  https://cloudogu.com/schulungen

<br/>
K8s Security series on JavaSPEKTRUM starting 05/2019

See also 🌐  https://cloudogu.com/blog

<a href='https://twitter.com/jschnatterer' class="social" target="_blank">
    <i class='fab fa-twitter'></i>
    @jschnatterer
</a>
<br/>
<a href='https://twitter.com/cloudogu' class="social" target="_blank">
    <i class='fab fa-twitter'></i>
    @cloudogu
</a>

<br/>
<br/>
Demo Source: 
<a href='https://github.com/cloudogu/k8s-security-demos' class="social" target="_blank">
    <i class='fab fa-github'></i>
    https://github.com/cloudogu/k8s-security-demos
</a>

Note: 
* JavaSPEKTRUM [05/2019: (27.09.2019)](https://www.sigs-datacom.de/fachzeitschriften/javaspektrum.html)