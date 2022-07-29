New-AzResourceGroup -Name "templateSpecs" -Location australiasoutheast

New-AzTemplateSpec -ResourceGroupName "templateSpecs" `
                   -Name "sample-vm" `
                   -DisplayName "Ubuntu VM with PublicIP" `
                   -Description "Ubuntu VM with PublicIP, requires an existing virtualNetwork" `
                   -Version "1.0" `
                   -Location australiasoutheast `
                   -TemplateFile c:\main.bicep `
                   -UIFormDefinitionFile C:\uiFormDefinition.json `
                   -Verbose
