
group=jasondel-aro
appid=7f8c7bc5-e7d0-4ea5-a58b-0db951fb0f64
tenantid=18fa92f1-bb4c-4ac2-9e49-799f97ca8eaf
admingroup=cade154e-665d-40c4-99c4-38970b762793
location=eastus2
workspaceid=e3076d9d-6a0f-485d-8a0a-5f597b309d0b
workspacename=jasondel-aro-workspace
vault=wthKeyVault

# az keyvault secret set --name aro-aad-secret \
#                        --vault-name $vault \
#                        --value $secret

secret=$(az keyvault secret show --name aro-aad-secret --vault-name $vault -o tsv --query "value") 

az group create --name $group -l $location
az openshift create --name $group -g $group \
    --aad-client-app-id=$appid \
    --aad-client-app-secret=$secret \
    --aad-tenant-id=$tenantid \
    --customer-admin-group-id=$admingroup

az group deployment create --resource-group $group \
   --template-file ./ExistingClusterOnboarding.json \
   --parameters @./existingClusterParam.json