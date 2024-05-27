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
This will return output with DNS addresses for both node services.

Example:
```sh
Outputs:

`Service1 = "a1f8e2bcdeb05487f8aa974d216a20af-35659930088016f9.elb.us-east-1.amazonaws.com"`
`Service2 = "a01031260234b4ed5aa8bb01b0d1e1d5-81237d2320b20da9.elb.us-east-1.amazonaws.com"`
```

## Connect to resources
---
- ##### MongoDB access:
  Forward mongo port to your localhost:
```sh
    kubectl port-forward --namespace default svc/mongodb 27017:27017 &
    mongosh --host 127.0.0.1 --authenticationDatabase admin -u root -p redhat
```

## Troubleshooting
---
If you encounter the following error during image creation:

`Error: Error pinging Docker server: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?`

Means terraform provider failed to connect to the docker daemon socket or `/var/run/docker.sock` symlink is broken.

You can find your Docker socket using the following command: `docker context ls`

>Example output:
```
NAME                DESCRIPTION                               DOCKER ENDPOINT                          ERROR
default             Current DOCKER_HOST based configuration   unix:///var/run/docker.sock
rancher-desktop *   Rancher Desktop moby context              unix:///Users/<user>/.rd/docker.sock
```

Either fix the broken symlink `/var/run/docker.sock` --> `/Users/<user>/.rd/docker.sock`

or just update your provider block accordingly with the socket address:
```
provider "docker" {
  host = "unix:///Users/<user>/.rd/docker.sock"
}
```
