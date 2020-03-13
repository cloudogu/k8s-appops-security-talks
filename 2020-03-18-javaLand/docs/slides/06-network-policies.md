<!-- .slide: data-background-image="images/subtitle.jpg"  -->
# 1. Network Policies <br/>(netpol)



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
* Securing Cluster Networking with Network Policies - Ahmet Balkan  
🎥 https://www.youtube.com/watch?v=3gGpMmYeEO8
* Interactively describes what a netpol does:  
```bash
kubectl describe netpol <name>
```



## Recommendation: Whitelist ingress traffic

In every namespace except `kube-system`:
 
* Deny ingress between pods,
* then whitelist all allowed routes.



## Advanced: ingress to `kube-system`

<font color="red">⚠</font> Might stop the apps in your cluster from working

Don't forget to:

* Allow external access to ingress controller  
* Allow access to kube-dns/core-dns to every namespace   

Note:
* Allow external access to ingress controller  
  (otherwise no more external access on any cluster resource)  
* Allow access to kube-dns/core-dns to every namespace   
  (otherwise no more service discovery by name)



## Advanced: egress

* Verbose solution: 
  * Deny egress between pods,
  * then whitelist all allowed routes,
  * repeating all ingress rules. 🙄
* More pragmatic solution:
  * Allow only egress within the cluster,
  * then whitelist pods that need access to internet.



## 🚧️Net pol pitfalls

* Whitelisting monitoring tools (e.g. Prometheus)
* Restart might be necessary (e.g. Prometheus)
* No labels on namespaces by default
* `egress` more recent than `ingress` rules and less sophisticated
* Policies might not be supported by CNI Plugin.  
  Testing!    
  🌐 https://www.inovex.de/blog/test-kubernetes-network-policies/

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
  ➜ different strengths, support each other  
  🌐 https://istio.io/blog/2017/0.1-using-network-policy/

Note: 
* no option for cluster-wide policies
* whitelisting egress for domain names instead of CIDRs
* filtering on L7 (e.g. HTTP or gRPC)
* netpols will not work in multi-cloud / cluster-federation scenarios

Possible solutions:
* Proprietary extensions of CNI Plugin (e.g. cilium or calico)
* Service Meshes: similar features, also work with multiple clusters;  
  operate on L7, NetPol on L3/4  
  ➜ different strengths, support each other  
  🌐 https://istio.io/blog/2017/0.1-using-network-policy/



## 🗣️ Demo

<img data-src="images/demo-netpol-wo-prometheus.svg" width=40% />  

* [nosqlclient](http://nosqlclient)
* [web-console](http://web-console/)

Note:
* curl --output /tmp/mongo.tgz https://downloads.mongodb.org/linux/mongodb-shell-linux-x86_64-3.4.18.tgz && tar xf /tmp/mongo.tgz -C /tmp
* /tmp/mongodb-linux-x86_64-3.4.18/bin/mongo users --host mongodb.production.svc.cluster.local --eval 'db.users.find().pretty()'  
-- Limited time: Only show ingress whitelisting
➜ Offtopic: MongoDB recommendation ➜ not `mongo` image but `bitnami/mongo` (helm chart)
* [Demo Script](/demo/2-network-policies/Readme.md) 
* [plantUml src](http://www.plantuml.com/plantuml/uml/dOzFQy904CNl-oc6zE0fD2gev514GNeGyI3qK3niigCisTr9zmzIYj-zcvYIOFySkgUPUVD-RtRfFBS-QCLS9KtDBTSWZKTxuYN21mDOyR8wMmf6h4cHXOV9b4-5Q1Io0cqt7SzcYuLWLpO0SMlfqaA6rhkbadHD1et_Hnh0XeplPflsDN3M_o1vFXps2N07snLZXaGShLLmKOST-WlP2lQaP2dH9V62YApZ2VmSztPSeuiTmgWA1QRkFThqg5c3-5uFbkD9LiU6ddHDSfEsgoEawLE_4yVNt-02JpmetuDVi80r6KSAZtTHBNIeGmuNBDBorkQBxA-asf88fPTa-Z13xasLIgBnFuODzHWsQFDfbcNV89rDapcJA1fBL-QFNyLadetdxPrNjaGZWbQV)
* [plantUml src with prometheus](http://www.plantuml.com/plantuml/uml/dKzDRnen4BtxLuosXvnMMKALK0vL15BKGnHnGEgXuc3iWLfhU-ZOBgeg_djdWMPNbEOGdpppFjwynvGrvnAyIgsBEyqwW8iPUQCDmcy5CDEctJALQEVaYU73tLYFhUqGOejytexkxoSJgmvgOAIPQNyq6KelI8R2ZYB6_8uqW2UA-RnxEhxENFKDgY_BvQ82dU1vfbGaAwkvBqbmUC6y9svXGTuPXwcI2yHo9oVehV1UTC0a4y9DMzPOfryY2pST3UHzMxB6ZMjNdNjr7geJz3nRGLr_xZcoFlpFtE965vzxuw-uXZd5H1vN5r57qo4EKzZZkZQdSJfftaeA55qcTd7RXosO0kRlMDBLh04iKRlNgKx8Fv4byDBcehceykaht4bpAons9hrrfgJOOhAZs9yPAVtmnZkC-UgTGrmY1-Dqt3JDloOdMQ2u9Rlk9EVlzFRlv-wX6JrSRzVh1i9Fe-RZQxrZluDwn6XBy7y0)



## 🎁 Wrap-Up: Network Policies

My recommendations:

* Ingress whitelisting in non-`kube-system` namespaces
* Use with care
  * whitelisting in `kube-system`
  * `egress` whitelisting for cluster-external traffic 