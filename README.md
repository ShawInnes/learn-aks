https://docs.microsoft.com/en-us/learn/modules/aks-workshop/01-introduction

```
az login

SUBSCRIPTION_ID=`az account list --query "[?name == 'Visual Studio Enterprise – MPN']" | jq -r ".[].id"`
az account set --subscription="$SUBSCRIPTION_ID"
```
