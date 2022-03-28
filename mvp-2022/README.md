
```bash
az stack sub create -n shared-services -f .\shared-services.bicep -l eastus2 --verbose

az stack sub create -n widget-app -f .\widgets.bicep -l eastus2 --verbose

az stack sub create -n widget-app -f .\empty.bicep -l eastus2 --update-behavior purgeResources

az stack sub create -n shared-services -f .\empty.bicep -l eastus2 --update-behavior purgeResources
```
