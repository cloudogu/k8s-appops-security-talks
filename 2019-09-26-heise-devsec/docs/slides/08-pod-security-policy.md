<!-- .slide: data-background-image="images/subtitle.jpg"  -->
# <font size="5">4 things every developer should know about K8s security?</font>

<h2 class="fragment">Pod Security Policies (PSP)</h2>



> a cluster-level resource \[..\] that define a set of conditions that a pod must run with in order to be accepted into the system

🌐 https://kubernetes.io/docs/concepts/policy/pod-security-policy/



* can be used to enforce security context cluster-wide   
* has additional options such as block pods that try to
  * enter node's Linux namespaces (net, PID, etc.)
  * mounting the docker socket, 
  * binding ports to nodes,
  * starting `privileged` containers
  * etc.
* more effort than security context and different syntax as in `securityContext` 🙄 
  
➜ Still highly recommended!




<div style="text-align: center;">
Too much ground to cover for 45 min!
</div>
<div style="font-size: 1000%;text-align: center;">
⏱️
</div>
<div style="text-align: center;">
See Demo Repo on last slide
</div>