export rg=knative
export aks_name=knative-aks
export location=eastus
export kversion=1.12.4
export vnet=aks-vnet
export subnet_nodes=aks-node-subnet
export subnet_virtual_nodes=aks-virtual-node-subnet
export node_size=Standard_B2s
export node_count=3

# create a group to hold all resources
az group create --name $rg --location $location

# create a virtual network for the cluster
az network vnet create \
    --resource-group $rg \
    --name $vnet \
    --address-prefixes 10.0.0.0/8 \
    --subnet-name $subnet_nodes \
    --subnet-prefix 10.240.0.0/16

# create a subnet for virtual nodes
az network vnet subnet create \
    --resource-group $rg \
    --vnet-name $vnet \
    --name $subnet_virtual_nodes \
    --address-prefix 10.241.0.0/16

# create the service principal
az ad sp create-for-rbac --skip-assignment
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

# Get the vnet and subnet ids 
vnetid=$(az network vnet show --resource-group $rg --name $vnet --query id -o tsv)
subnetid=$(az network vnet subnet show -g $rg --vnet-name $vnet --name $subnet_nodes --query {id:id} --o tsv)

# Allow AKS to use virtual network
az role assignment create --assignee $appId --scope $vnetid --role Contributor

az aks create \
    --resource-group $rg \
    --name $aks_name \
    --node-count $node_count \
    --network-plugin azure \
    --service-cidr 10.0.0.0/16 \
    --dns-service-ip 10.0.0.10 \
    --docker-bridge-address 172.17.0.1/16 \
    --vnet-subnet-id $subnetid \
    --service-principal $appId \
    --client-secret $password \
    --kubernetes-version $kversion \
    --node-vm-size $node_size \
    --generate-ssh-keys

# Enable Azure CLI extension
az extension add --source https://aksvnodeextension.blob.core.windows.net/aks-virtual-node/aks_virtual_node-0.2.0-py2.py3-none-any.whl

# Install virtual node add-on to cluster.
az aks enable-addons \
    --resource-group $rg \
    --name $aks_name \
    --addons virtual-node \
    --subnet-name $subnet_virtual_nodes
