for fn in `az group list --query "[?contains(name, 'jasondel-aks')].{Name: name}" -o tsv`; do
    echo "the group is $fn"
    az group delete --name $fn --yes
done

