The prototype environment consists of MongoDB and two Node apps deployed on EKS.

Both Node services use the same image but different `ENTRYPOINT`: `["node", "/service1/index.js"] or  ["node", "/service2/index.js"]`

MongoDB installed from bitnami/mongodb chart

Node app chart can be found in `./k8s` folder.

##  Infrastructure provision and code deploy
---
#### 1. Create aws infrastructure (vpc & eks cluster):
```sh
cd terraform-infra
terraform init
terraform apply
```
#### 2. Create node app docker image (this will return the image ECR url):
```sh
cd terraform-docker-image
terraform init
terraform apply
```
#### 3. Update kubeconfig:
```sh
aws eks --region us-east-1 update-kubeconfig --name <cluster name>
```
#### 4. Deploy both node-app and MongoDb.
Admin, user and db variables for both mongo and node app are configured inside `./terraform-helm/main.tf`, feel free to prowide your own.
```
cd terraform-helm
terraform init
terraform apply
```

## Connect to resources
---
- ##### Node app access:
  Since there's no Route53 integration, Ingress maps services to a dummy domain: `service1-node-app.io` & `service2-node-app.io`
  In order to access them please update /etc/hosts file: 
```sh
IP=$(nslookup $(kubectl get ingress node-app-ingress|awk 'NR==2 {print $4}')|awk '/Address:/ {print $2}'|tail -n 1) && echo -e "${IP} service1-node-app.io\n${IP} service2-node-app.io"|sudo tee -a /etc/hosts
```
- ##### MongoDB access:
  Forward mongo port to your localhost:
```sh
    kubectl port-forward --namespace default svc/mongodb 27017:27017 &
    mongosh --host 127.0.0.1 --authenticationDatabase admin -u root -p redhat
```

## Cleanup
---
- ##### Uninstall helm releases
```sh
cd terraform-helm
terraform destroy
```
- ##### Delete EKS cluster and ECR repo
```sh
cd terraform-docker-image
terraform destroy
```
```
cd terraform-infra
terraform destroy
```
