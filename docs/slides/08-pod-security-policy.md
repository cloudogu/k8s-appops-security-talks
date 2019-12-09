<!-- .slide: data-background-image="images/subtitle.jpg"  -->
# 3. Pod Security Policies <br/>(PSP) 



* enforce security context cluster-wide   
* additional options for blocking pods trying to
  * enter node's Linux namespaces (net, PID, etc.)
  * mounting docker socket, 
  * binding ports to nodes,
  * starting `privileged` containers
  * etc.
* more effort than security context and different syntax  🙄 
  
➜ Still highly recommended!



## Recommendation


<a href="https://github.com/cloudogu/k8s-security-demos/blob/master/4-pod-security-policies/demo/01-psp-restrictive.yaml"><img data-src="images/psp.png" width="80%" style="filter: blur(2px);-webkit-filter: blur(2px);"/></a>

<i class='fab fa-github'></i> https://github.com/cloudogu/k8s-security-demos/blob/master/4-pod-security-policies/demo/01-psp-restrictive.yaml



<!-- .slide: style="text-align: center;"  -->
## Too much ground to cover for 45 min!
<div style="font-size: 800%">
⏱️
</div>
See Demo Repo on last slide