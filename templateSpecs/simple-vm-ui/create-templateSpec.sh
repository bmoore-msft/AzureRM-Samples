az group create -n "templateSpecs" -l "australiasoutheast"

az ts create \
  --resource-group "templateSpecs" \
  --name "sample-vm" \
  --display-name "Ubuntu VM with PublicIP" \
  --description "Ubuntu VM with PublicIP, requires an existing virtualNetwork" \
  --version "1.0" \
  --location "australiasoutheast" \
  --template-file main.bicep \
  --ui-form-definition uiFormDefinition.json
