https://docs.microsoft.com/en-us/learn/modules/aks-workshop/01-introduction

Current progress:  https://docs.microsoft.com/en-us/learn/modules/aks-workshop/07-deploy-ingress

```
az login

SUBSCRIPTION_ID=`az account list --query "[?name == 'Visual Studio Enterprise – MPN']" | jq -r ".[].id"`
az account set --subscription="$SUBSCRIPTION_ID"
```

```
az ad sp create-for-rbac --name http://terraform

export TF_VAR_client_id=appId
export TF_VAR_client_secret=password
```

```
terraform apply

echo "$(terraform output kube_config)" > ./azurek8s
export KUBECONFIG=./azurek8s
export ACR_NAME=$(terraform output acr_name)
export AKS_CLUSTER_NAME=$(terraform output cluster_name)
export RESOURCE_GROUP=$(terraform output resource_group)

az aks update \
    --name $AKS_CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --attach-acr $ACR_NAME
```

```
kubectl get namespace
kubectl create namespace ratingsapp
```

```
cd mslearn-aks-workshop-ratings-api

az acr build \
    --registry $ACR_NAME \
    --image ratings-api:v1 .
```

## Install MongoDB
```
helm repo add bitnami https://charts.bitnami.com/bitnami

helm install ratings bitnami/mongodb \
    --namespace ratingsapp \
    --set mongodbUsername=mongouser,mongodbPassword=mongopass,mongodbDatabase=ratingsdb

# helm uninstall ratings --namespace ratingsapp
```

## Connect to MongoDB
```
export MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace ratingsapp ratings-mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)
export MONGODB_PASSWORD=$(kubectl get secret --namespace ratingsapp ratings-mongodb -o jsonpath="{.data.mongodb-password}" | base64 --decode)
kubectl port-forward --namespace ratingsapp svc/ratings-mongodb 27017:27017 &
mongo --host 127.0.0.1 --authenticationDatabase admin -p $MONGODB_ROOT_PASSWORD
```
