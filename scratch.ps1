
$TemplateSchema = "https://schema.management.azure.com/schemas/2019-08-01/deploymentTemplate.json#"

switch -Wildcard ($TemplateSchema){
    '*tenatDeploymentTemplate.json*' {
        $deploymentScope = "Tenant"
    }
    '*managementGroupDeploymentTemplate.json*' {
        $deploymentScope = "ManagementGroup"
    }
    '*subscriptionDeploymentTemplate.json*' {
        $deploymentScope = "Subscription"
    }
    '*/deploymentTemplate.json*' {
        $deploymentScope = "ResourceGroup"
    }
}

Write-Host "out: $deploymentScope"
