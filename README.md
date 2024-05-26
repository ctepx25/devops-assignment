### 1. Create aws infrastructure (vpc & eks cluster) and update kubeconfig:
```sh
cd terraform-infra
terraform init
terraform apply
aws eks --region us-east-1 update-kubeconfig --name <cluster name>
```
### 2. Create node app docker image (this will return the image ECR url):
```sh
cd terraform-infra
terraform init
terraform apply
```
### 3. Deploy both node-app and MongoDb.
```
cd terraform-helm
terraform init
terraform apply
```

