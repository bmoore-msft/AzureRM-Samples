<#
Export all managementGroups and children (managementGroups and subscriptions) under the specified root
#>

param(
    [string] [Parameter(mandatory = $true)]$root
)

Import-Module "$PSScriptRoot/.modules/export-policyDefinitions.psm1" -Force
Import-Module "$PSScriptRoot/.modules/export-policySetDefinitions.psm1" -Force
Import-Module "$PSScriptRoot/.modules/export-policyAssignments.psm1" -Force

# function to recurse the managementGroup heirarchy
function Get-Children($id, $children, [array]$output){

    Write-Host "Group: $id"
    
    foreach($c in $children){ # Get the subscriptions in the mg
        Get-Children $c.id $c.children $output
        # mg and subscription children have a different schema 
        if($c.type -like "*Microsoft.Management/managementGroups*"){
            $mgName = $c.id.split("/")[-1]
        }
    }
    if(![string]::IsNullOrWhiteSpace($mgName)){
        $output = $output += $mgName
    }
    return $output
}

# Get the top-level or root group for export
$mg = Get-AzManagementGroup -GroupName $root -Expand -Recurse

$mgs = @()
$mgs = Get-Children $mg.id $mg.children $mgs

$mgs += $root
$mgs = $mgs | Select -Unique
[array]::Reverse($mgs) # reverse the order for dependencies to be honored

$tenantId = (Get-AzContext).Tenant.Id

foreach($g in $mgs){
    Write-Host "Exporting group: $g"
    
    $mg = Get-AzManagementGroup -GroupName $g -Expand
    
    if($mg.ParentName -ne $tenantId){
        $parentMg = $mg.ParentName
    }else{
        $parentMg = ""
    }

    # managementGroup parameter value
    $managmentGroupParam = [ordered]@{
        name = $mg.Name
        parentName = $parentMg
        displayName = $mg.displayName
    }

    # subscriptions parameter value
    $subscriptionsParam = @()
    foreach($c in $mg.Children){
        if($c.Type -eq "/subscriptions"){
            $subscriptionsParam += $c.Name
        }
    }

    # policy defintions - API returns all of them, even though you ask for scope
    Write-Host "Get policy definitions for managementGroup: $g"
    $pds = Get-AzPolicyDefinition -Custom -ManagementGroupName $g 
    $policyDefParam = @()
    foreach($pd in $pds){
        # see if this definition is actually deployed to this group since the API returns everything above it, if it is, add it to the list
        if($pd.resourceId -like "*Microsoft.Management/managementGroups/$g*"){
            $policyDefParam += $pd.name
            # Get PolicyDef JSON
            $json = Get-PolicyDefinitionObject $pd
            # Write parameter file
            $json | ConvertTo-Json -Depth 20 | Set-Content -Path "$PSScriptRoot/policyDefinitions/$($pd.name).parameters.json"
        }
    }

    # policy Sets
    Write-Host "Get policy sets for managementGroup: $g"
    $psds = Get-AzPolicySetDefinition -Custom -ManagementGroupName $g 
    $policySetDefParam = @()
    foreach($psd in $psds){
        if($psd.resourceId -like "*Microsoft.Management/managementGroups/$g*"){
            $policySetDefParam += $psd.name
            # Get PolicySet JSON
            $json = Get-PolicySetDefinitionObject $psd
            # Write parameter file
            $json | ConvertTo-Json -Depth 50 | Set-Content -Path "$PSScriptRoot/policySetDefinitions/$($psd.name).parameters.json"
        }
    }

    # policy assignments
    Write-Host "Get policy assignments for managementGroup: $g"
    $pas = Get-AzPolicyAssignment -Scope "/providers/Microsoft.Management/managementGroups/$g"
    $policyAssignmentParam =@()
    foreach($pa in $pas){
        if($pa.ResourceId -like "*Microsoft.Management/managementGroups/$g*"){
            $policyAssignmentParam += $pa.Name
            # Get PolicyAssignment JSON
            $json = Get-PolicyAssignmentObject $pa
            # Write parameter file
            $json | ConvertTo-Json -Depth 50 | Set-Content -Path "$PSScriptRoot/policyAssignments/$($pa.name).parameters.json"
        }
    }

    $mgParamFile = [ordered]@{
        '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
        contentVersion = "1.0.0.0"
        parameters = [ordered]@{
            managementGroup = @{
                value = $managmentGroupParam
            }
            subscriptions = @{
                value = $subscriptionsParam
            }
            policyDefinitions = @{
                value = $policyDefParam
            }
            policySetDefinitions = @{
                value = $policySetDefParam
            }
            policyAssignments = @{
                value = $policyAssignmentParam
            }
        }
    }

    $mgParamFile | ConvertTo-Json -Depth 30 | Set-Content -path "$PSScriptRoot\ManagementGroups\$g.parameters.json" 

}

# reverse the array, because sequence matters for the loop and improves readability in the template
#$orderedOutput = [array]::Reverse($output)

# Separate the MG and the Subscriptions as they have different lifecycles and need different files
#$mgs = @()
#$subs = @()

<#foreach($item in $output){
    if($item.Contains('subscriptionId')){
        $subs += $item
    }else{
        if($item.count -gt 0){
            $mgs += $item
        }
    }
}
#>

# Create the param file for the managementGroup template that uses a copy loop
$mainTemplateParamFile = [ordered]@{
    '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
    contentVersion = "1.0.0.0"
    parameters = @{
        groups = @{
            value = $mgs
        }
    }
}

# Create the param file for the subscription template
<#$subParamFile = [ordered]@{
    '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
    contentVersion = "1.0.0.0"
    parameters = @{
        subscriptions = @{
            value = @{
                items = $subs
            }
        }
    }
}
#>
<#
# Alternative approach to create a single template file for managementGroups, common case is a small number of groups
$mgTemplateFile = @{}

# create a template file with each group

$resources = @()
foreach($mg in $mgs){

    if($mg.parentName -ne ""){
        $dependsOn = @(
            "[tenantResourceId('Microsoft.Management/managementGroups', `'$($mg.parentName)`')]"
        )
        $details = @{
            parent = @{
                id = "[tenantResourceId('Microsoft.Management/managementGroups', `'$($mg.parentName)`')]"
            }
        }
    }else{
        $dependsOn = $null
        $details = $null
    }

    $resources += [ordered]@{
        type = "Microsoft.Management/managementGroups"
        apiVersion = "2020-05-01"
        name = $mg.name
        dependsOn = $dependsOn
        properties = [ordered]@{
            displayName = $mg.displayName
            details = $details
        }
    }

}

$mgTemplate = [ordered]@{
    '$schema' =  "https://schema.management.azure.com/schemas/2019-08-01/tenantDeploymentTemplate.json#"
    contentVersion = "1.0.0.0"
    resources = $resources
}
#>

# Write the files
#$mgTemplate | ConvertTo-Json -Depth 30 | Set-Content -path ".\managementGroups.json" 
$mainTemplateParamFile | ConvertTo-Json -Depth 30 | Set-Content -path ".\azureDeploy.parameters.json" 
#$subParamFile | ConvertTo-Json -Depth 30 | Set-Content -path ".\subscriptions-managementGroups.loop.parameters.json"
