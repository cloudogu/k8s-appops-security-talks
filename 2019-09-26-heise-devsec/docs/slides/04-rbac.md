# 1. RBAC



<!-- .slide: style="text-align: center;" -->
<img data-src="images/boring.jpg" class="centered"/>

🌐 https://memegenerator.net/instance/83566913/homer-simpson-boring



* RBAC active by default since K8s 1.6
* ... but not if you migrated!



* Every Container is mounted the token of its service account at   
  `/var/run/secrets/kubernetes.io/serviceaccount/token`
  * With RBAC the default service account is only authorized to read publicly accessible API info
  * <font color="red">⚠</font> With legacy authz the default service account is cluster admin
* You can test if your pod is authorized by executing the following in it:

```bash
curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  https://${KUBERNETES_SERVICE_HOST}/api/v1/secrets
```

* If a pod does not need access to K8s API, mounting the token can be disabled in the pod spec:  
  `automountServiceAccountToken: false`  



## 🐐 Demo

<img data-src="images/demo-rbac.svg"/>

* [legacy-authz](http://legacy-authz)
* [RBAC](http://rbac)

Note:
* [plantUml src](http://www.plantuml.com/plantuml/svg/dL8zQyCm4DtrAmvtoEIX3OHC9RKXT0Ybj84E9SF5khWXicHE4gKj-UyzsQOr8KkYxTwzZtUWXG_88JP6-SFUjiZOmDu6uXrM13yAeC3gKBEBLfVEE8QRkobEjKuRnvfuG6zdi_bSgwCQ6I6p--nCnj8JKkMQrbcouOeqWAMpOS2MtKlcwl-2x76zVdxD03si2gMiquAL9deXWA4Qgo_063w-CubN0AtaOosS9sp8oqGmqRJ3QCAaSyc6AU_5IGRotjzeArTQxmn1lzfqz16UzSnLiO4ylpyh4ORqFvuMVIaUoeiByXQhi_MIsqNbak2lseAiJl_b5m00)
