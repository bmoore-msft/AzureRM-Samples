param(
    [string] [Parameter(mandatory = $true)]$root
)

Write-Host "Exporting ManagementGroup hierarchy..."
Invoke-Expression "$PSScriptRoot/01-ManagementGroups/export-mg.ps1 -root $root"
Write-Host "Exporting Policy Definitions..."
Invoke-Expression "$PSScriptRoot/03-PolicyDefinitions/export-policyDefinitions.ps1 -root $root"
Write-Host "Exporting Policy Set Definitions..."
Invoke-Expression "$PSScriptRoot/03-PolicyDefinitions/export-policySetDefinitions.ps1 -root $root"
Write-Host "Exporting Policy Assignments..."
Invoke-Expression "$PSScriptRoot/04-PolicyAssignments/export-policyAssignments.ps1 -root $root"

Write-Host "Creating azuredeploy.parameters.json..."

$mgs = Get-Content "$PSScriptRoot/01-ManagementGroups/managementGroups.parameters.json" -Raw | ConvertFrom-Json
$subs = Get-Content "$PSScriptRoot/02-Subscriptions/subscriptions-managementGroups.parameters.json" -Raw | ConvertFrom-Json
$policyDefinitions = Get-Content "$PSScriptRoot/03-PolicyDefinitions/policyDefinitions.parameters.json" -Raw | ConvertFrom-Json
$policySetDefintions = Get-Content "$PSScriptRoot/03-PolicyDefinitions/policySetDefinitions.parameters.json" -Raw | ConvertFrom-Json
$policyAssignments = Get-Content "$PSScriptRoot/04-PolicyAssignments/policyAssignments.parameters.json" -Raw | ConvertFrom-Json

$ParamFile = [ordered]@{
    '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
    contentVersion = "1.0.0.0"
    parameters = [ordered]@{
        groups = @{
            value = $mgs.groups.value
        }
        subscriptions = @{
            value = $subs.subscriptions.value
        }
        policyDefinitions = @{
            value = $policyDefinitions.policyDefinitions.value
        }
        policySetDefinitions = @{
            value = $policySetDefintions.policySetDefinitions.value
        }
        policyAssignments = @{
            value = $policyAssignments.policyAssignments.value
        }
    }
}

$paramFile | ConvertTo-Json -Depth 50 | Set-Content -Path "$PSScriptRoot\azuredeploy.parameters.json"
