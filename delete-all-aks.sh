for fn in `az group list --query "[?contains(name, 'jasondel') && contains(name, 'aks')].{Name: name}" -o tsv`; do
    echo "the group is $fn"
    az group delete --name $fn --yes
done

