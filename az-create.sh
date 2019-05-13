export rg=jasondel-aks3
export aks_name=jdlaks3
export location=eastus
export kversion=1.14.0
# export vnet=aks-vnet
# export subnet_nodes=aks-node-subnet
# export subnet_virtual_nodes=aks-vnode-subnet
export node_size=Standard_D2
export node_count=1

# Ensure that your susbscription is registered to use ACI
# az provider register --namespace Microsoft.ContainerInstance

# create a group to hold all resources
az group create --name $rg --location $location --tags owner=jasondel

# create a virtual network for the cluster
# az network vnet create \
#     --resource-group $rg \
#     --name $vnet \
#     --address-prefixes 10.0.0.0/8 \
#     --subnet-name $subnet_nodes \
#     --subnet-prefix 10.240.0.0/16

# create a subnet for virtual nodes
# az network vnet subnet create \
#     --resource-group $rg \
#     --vnet-name $vnet \
#     --name $subnet_virtual_nodes \
#     --address-prefix 10.241.0.0/16

# create the service principal
#az ad sp create-for-rbac --skip-assignment
# NOTE:
# grab appId and password from the output
#
# {
#   "appId": "d6fe7e3e-0787-4515-a466-b8a68c7cb259",
#   "displayName": "azure-cli-2019-02-01-19-40-29",
#   "name": "http://azure-cli-2019-02-01-19-40-29",
#   "password": "79625caf-bd78-4c61-9135-03165676dd0c",
#   "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
# }
export appId=d6fe7e3e-0787-4515-a466-b8a68c7cb259
export password=79625caf-bd78-4c61-9135-03165676dd0c

# Create a contributor role assignment with a scope of the ACR resource. 
#SP_PASSWD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --role Reader --scopes $ACR_REGISTRY_ID --query password --output tsv)

# Get the service principle client id.
#CLIENT_ID=$(az ad sp show --id http://$SERVICE_PRINCIPAL_NAME --query appId --output tsv)


# Get the vnet and subnet ids 
# vnetid=$(az network vnet show --resource-group $rg --name $vnet --query id -o tsv)
# subnetid=$(az network vnet subnet show -g $rg --vnet-name $vnet --name $subnet_nodes --query {id:id} --o tsv)

# Allow AKS to use virtual network
# az role assignment create --assignee $appId --scope $vnetid --role Contributor

#az extension add --name aks-preview

az aks create \
    --resource-group $rg \
    --name $aks_name \
    --network-plugin azure \
    --service-principal $appId \
    --client-secret $password \
    --kubernetes-version $kversion \
    --node-vm-size $node_size \
    --generate-ssh-keys \
    --node-count $node_count \
    --enable-vmss \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count $(expr $node_count + 3) \
    --network-policy calico

# Grab the credentials.
az aks get-credentials --overwrite-existing -g $rg -n $aks_name

# Enable Azure CLI extension
#az extension add --source https://aksvnodeextension.blob.core.windows.net/aks-virtual-node/aks_virtual_node-0.2.0-py2.py3-none-any.whl

# Install virtual node add-on to cluster.
# az aks enable-addons \
#     --resource-group $rg \
#     --name $aks_name \
#     --addons virtual-node \
#     --subnet-name $subnet_virtual_nodes

# # Install helm (locally)
# brew install kubernetes-helm

# # Install tiller on the K8S cluster
# helm init


# Install istio (without HELM)
#kubectl apply --filename https://github.com/knative/serving/releases/download/v0.3.0/istio-crds.yaml && \
#kubectl apply --filename https://github.com/knative/serving/releases/download/v0.3.0/istio.yaml

# Specify the Istio version that will be leveraged throughout these instructions
# ISTIO_VERSION=1.0.5

# # MacOS
# curl -sL "https://github.com/istio/istio/releases/download/$ISTIO_VERSION/istio-$ISTIO_VERSION-osx.tar.gz" | tar xz

# cd istio-$ISTIO_VERSION
# helm install install/kubernetes/helm/istio --name istio --namespace istio-system \
#   --set global.controlPlaneSecurityEnabled=true \
#   --set grafana.enabled=true \
#   --set tracing.enabled=true \
#   --set kiali.enabled=true \
#   --set sidecarInjectorWebhook.enabled=false
  

  
