
$templateSpecResourceGroupName = "demo-templateSpecs"
$templateSpecName = "app-vnet-deployment"
$templateSpecVersion = "0.3"

# this creates a new templateSpec from the bicep template
New-AzTemplateSpec -ResourceGroupName $templateSpecResourceGroupName `
                   -Name $templateSpecName `
                   -TemplateFile .\ts-deploy-vnet.bicep `
                   -Location southcentralus `
                   -DisplayName "Base Network Setup" `
                   -VersionDescription "minor updates" `
                   -Version $templateSpecVersion

# once created you can use the resourceId for deploying an instance of the templateSpec
$templateSpecId = (Get-AzTemplateSpec -Name $templateSpecName -Version $templateSpecVersion -ResourceGroupName $templateSpecResourceGroupName).Id

# a deep link to the templateSpec in the portal can be shared with those who have access
$tenantId = (Get-AzContext).Tenant.Id
$deepLink = "https://portal.azure.com/#$tenantId/resource$templateSpecId"
Write-Host $deepLink

# during deployment parameters accepted by the templateSpec can be provided, "environment" in this sample
New-AzSubscriptionDeployment -Location southcentralus -TemplateSpecId $templateSpecId -Verbose -environment 'test'

