#ingress.sh

publicip_rg=shared
publicip_name=jasondel-publicip
publicip=$(az network public-ip show -o tsv --query ipAddress -g $publicip_rg -n $publicip_name)
subscription=$(az account show -o tsv --query id)
appId=d6fe7e3e-0787-4515-a466-b8a68c7cb259

az role assignment create \
   --assignee $appId \
   --role "Contributor" \
   --scope /subscriptions/$subscription/resourceGroups/$publicip_rg

# Create a namespace for your ingress resources
kubectl create namespace ingress

# Use Helm to deploy an NGINX ingress controller
helm install ingress stable/nginx-ingress \
    --namespace ingress \
    --set controller.replicaCount=2 \
    --set controller.service.loadBalancerIP="$publicip" \
    --set controller.service.annotations=["service.beta.kubernetes.io/azure-load-balancer-resource-group=\"$publicip_rg\""]
