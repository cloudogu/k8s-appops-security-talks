<!-- .slide: data-background-image="images/subtitle.jpg"  -->
# Network Policies <br/>(netpol)



A "firewall" for communication between pods.

* Applied to pods 
  * within namespace
  * via labels
* Ingress / egress
  * to/from pods (in namespaces) or CIDRs (egress only)
  * for specific ports (optional)
* Enforced by the CNI Plugin (e.g. Calico)
* <font color="red">⚠</font> No Network Policies: All traffic allowed



## <i class='fas fa-thumbtack'></i> Helpful to get started

<img data-src="images/network-policy-allow-external.gif" width=75% />

* <i class='fab fa-github'></i> https://github.com/ahmetb/kubernetes-network-policy-recipes  
* Interactively describes what a netpol does:  
```bash
kubectl describe netpol <name>
```



## Recommendation: Restrict ingress traffic

In all application namespaces (not `kube-system`, operators, etc.):
 
* Deny ingress between pods,
* then allow specific routes only.



## Advanced: Restrict egress to the outside

* Verbose solution: 
  * Deny egress between pods,
  * then allow specific routes,
  * repeating all ingress rules. 🙄
* More pragmatic solution:
  * Allow only egress within the cluster,
  * then allow specific pods that need access to internet.

<font color="red">⚠</font> egress target IP addresses might be difficult to maintain




## Advanced: Restrict `kube-system` / operator traffic

<font color="red">⚠</font> Might stop the apps in your cluster from working

Don't forget to:

* Allow external ingress to ingress controller  
* Allow access to DNS from every namespace   
* Allow DNS egress to the outside (if needed)  
* Allow operators egress (Backup, LetsEncrypt, external-dns, Monitoring, Logging, GitOps-Repo, Helm Repos, etc.)

Note:
* Allow external access to ingress controller  
  (otherwise no more external access on any cluster resource)  
* Allow access to kube-dns/core-dns to every namespace  
  (otherwise no more service discovery by name)
* Allow DNS egress to the outside (if needed)  
  (otherwise no resolution of external names)



## 🚧️ Net pol pitfalls

* Allow monitoring tools (e.g. Prometheus)
* Restart might be necessary (e.g. Prometheus)
* No labels on namespaces by default
* Allowing egress to API server difficult  
  <i class="fab fa-stack-overflow"></i> https://stackoverflow.com/a/56494510/
* Policies might not be supported by CNI Plugin.  
  ➡️ Testing!    
  🌐 https://www.inovex.de/blog/test-kubernetes-network-policies/
  <i class='fab fa-github'></i> https://github.com/inovex/illuminatio

Note:
* Matching both pods and namespace needs k8s 1.11+
* Restart might be necessary for the netpol to become effective
* In order to match namespaces, labels need to be added to the namespaces, e.g.

```bash
kubectl label namespace/kube-system namespace=kube-system
```
* On GKE: "at least 2 nodes of type n1-standard-1" are required
* Restricting `kube-system` might be more of a challenge (DNS, ingress controller)



## More Features?

* Proprietary extensions of CNI Plugin (e.g. cilium or calico)
* Service Meshes: similar features, also work with multiple clusters  
  ➡️ different strengths, support each other (ISO/OSI Layer 7 vs 3/4)  
  🌐 https://istio.io/blog/2017/0.1-using-network-policy/

Note: 
* no option for cluster-wide policies
* allow egress for domain names instead of CIDRs
* filtering on L7 (e.g. HTTP or gRPC)
* netpols will not work in multi-cloud / cluster-federation scenarios

Possible solutions:
* Proprietary extensions of CNI Plugin (e.g. cilium or calico)
* Service Meshes: similar features, also work with multiple clusters;  
  operate on L7, NetPol on L3/4  
  ➡️ different strengths, support each other  
  🌐 https://istio.io/blog/2017/0.1-using-network-policy/



## 🗣️ Demo

<img data-src="images/demo-netpol.svg" width=40% />  

* [nosqlclient](http://nosqlclient)
* [web-console](http://web-console/)

Note:
* curl https://fastdl.mongodb.org/linux/mongodb-shell-linux-x86_64-debian92-4.4.1.tgz | tar zxv -C /tmp
* mv /tmp/mongo*/bin/mongo /tmp/
* /tmp/mongo users --host mongodb.production.svc.cluster.local --eval 'db.users.find().pretty()'
-- Limited time: Only show allowing of ingress (until `3-ingress-production-allow-nosqlclient-mongo.yaml`)
* [Demo Script](https://github.com/cloudogu/k8s-security-demos/blob/master/2-network-policies/Readme.md) 
* [plantUml src](https://www.plantuml.com/plantuml/uml/dL1BQzj04BxhLspLGawoP9icGfGG70Y5Xf23eOVMXzNks5wqcjdk0rEA_tjtPRKMwGCJNRGptsE-cJldkVMXrzaRXK872S5gjlVUkAOiBJ_CTihlGniSM47e0VrCK5_sIkmLwD9eZabUTA45Y-315SvO5Vzbpvq7Mrfm5Ao0igj_OqL0pLlG88l5UoFyJAK8cUiK6cvvpnH6wPOBO3yonbPST3jB0UKzQRBixMB9br8cXAm4EtRdrzTrBRFZr8XRIuV1P2fzGOeR6K90_uffZ3qG-h7tC7p9F3jla7zShvzpnXrxN6KPaeojJxLZzpga0-LnQ7GnSIhVHUY9z-1C4bwbenRkUsJrLud6ulTbRJbiLRT9XlbOv2VeSRLXHN5xvcHiibl-uHs2DwHll-8J-6VIRaY5PXvvnt-5aB3bGVjpWC_GncEY8msR5v66uLESDUm0RI5EPLDN5oPQ_2-HiII3y8emXRhGSNcAYkI-QQ5L9Fyr_1IFuITbiwogwW-JKTOJxaYsIJ8-c_BNOt5JpM-6VOxP7Q0ClVu9)
➡️ Offtopic: MongoDB recommendation ➡️ not `mongo` image but `bitnami/mongo` (helm chart)



## 🎁 Wrap-Up: Network Policies

My recommendations:

* In all application namespaces: allow selected ingress traffic only.
* Use with care
  * restricting `egress` for cluster-external traffic 
  * restrict traffic in `kube-system` and for operators
