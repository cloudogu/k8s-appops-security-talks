<!-- .slide: data-background-image="images/subtitle.jpg"  -->
# 0. Role Base Access Control <br/> (RBAC)



<!-- .slide: style="text-align: center;" -->
<img data-src="images/boring.jpg" class="centered"/>

<font size="1">🌐 https://memegenerator.net/instance/83566913/homer-simpson-boring</font>



* RBAC active by default since K8s 1.6
* ... but not if you migrated!



* Try&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
```bash
curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  https://${KUBERNETES_SERVICE_HOST}/api/v1/secrets
```
* If not needed, disable access to K8s API                                                                                                                                      
```yaml
automountServiceAccountToken: false  
```



## 🗣️ Demo

<img data-src="images/demo-rbac.svg"/>  

* [legacy-authz](http://legacy-authz)
* [RBAC](http://rbac)

Note:
* `curl -k https://$KUBERNETES_SERVICE_HOST/api/v1/namespaces/default/secrets/web-console -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"`
* `k create rolebinding web-console --clusterrole admin --serviceaccount default:web-console`
* [Demo Script](/demo/1-rbac/Readme.md) 
* [plantUml src](http://www.plantuml.com/plantuml/svg/dL8zQyCm4DtrAmvtoEIX3OHC9RKXT0Ybj84E9SF5khWXicHE4gKj-UyzsQOr8KkYxTwzZtUWXG_88JP6-SFUjiZOmDu6uXrM13yAeC3gKBEBLfVEE8QRkobEjKuRnvfuG6zdi_bSgwCQ6I6p--nCnj8JKkMQrbcouOeqWAMpOS2MtKlcwl-2x76zVdxD03si2gMiquAL9deXWA4Qgo_063w-CubN0AtaOosS9sp8oqGmqRJ3QCAaSyc6AU_5IGRotjzeArTQxmn1lzfqz16UzSnLiO4ylpyh4ORqFvuMVIaUoeiByXQhi_MIsqNbak2lseAiJl_b5m00)
