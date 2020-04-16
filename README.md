https://docs.microsoft.com/en-us/learn/modules/aks-workshop/01-introduction

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
```

```
kubectl get namespace
kubectl create namespace ratingsapp
```
