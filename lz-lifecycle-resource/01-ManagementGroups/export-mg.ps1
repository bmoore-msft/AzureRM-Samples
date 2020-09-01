<#
Export all managementGroups and children (managementGroups and subscriptions) under the specified root
#>

param(
    [string] [Parameter(mandatory = $true)]$root
)

# function to recurse the managementGroup heirarchy
function Get-Children($id, $children, [array]$output){

    Write-Host "Group: $id"
    
    foreach($c in $children){
        Get-Children $c.id $c.children $output
        
        # mg and subscription children have a different schema 
        if($c.type -like "*/managementGroups"){
            $param = [ordered]@{
                managementGroupId = ($c.id).Replace("/providers/", "")
                displayName = $c.displayName
                parentId = $id.Replace("/providers/", "") #.Split("/")[-1] # name is the last segment of the resourceId
            }
        }else{
            $param = [ordered]@{
                subscriptionId = ($c.id).Replace("/subscriptions/", "")
                displayName = $c.displayName
                parentId = $id.Replace("/providers/", "") #.Split("/")[-1]
            }
        }
    }
    if($param.Count -ne 0){
        $output = $output += $param
    }
    return $output
}

$output = @([ordered]@{})

# Get the top-level or root group for export
$mg = Get-AzManagementGroup -GroupName $root -Expand -Recurse

$output = Get-Children $mg.id $mg.children $output

# The top-level group is the last one added before reversing the array
$output = $output += [ordered]@{
    managementGroupId = "Microsoft.Management/managementGroups/$root"
    displayName = $mg.displayName
    parentId = ""
}

# reverse the array, because sequence matters for the loop and improves readability in the template
$orderedOutput = [array]::Reverse($output)

# Separate the MG and the Subscriptions as they have different lifecycles and need different files
$mgs = @()
$subs = @()

foreach($item in $output){
    if($item.Contains('subscriptionId')){
        $subs += $item
    }else{
        if($item.count -gt 0){
            $mgs += $item
        }
    }
}

# Create the param file for the managementGroup template that uses a copy loop
$mgParamFile = [ordered]@{
    '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
    contentVersion = "1.0.0.0"
    parameters = @{
        groups = @{
            value = @{
                items = $mgs
            }
        }
    }
}

# Create the param file for the subscription template
$subParamFile = [ordered]@{
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

# Alternative approach to create a single template file for managementGroups, common case is a small number of groups
$mgTemplateFile = @{}

# create a single template file with each group
<#
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

# $mgTemplate | ConvertTo-Json -Depth 30 | Set-Content -path "$PSScriptRoot\managementGroups.single.json" 
$mgParamFile.Parameters | ConvertTo-Json -Depth 30 | Set-Content -path "$PSScriptRoot\managementGroups.parameters.json" 
$subParamFile.Parameters | ConvertTo-Json -Depth 30 | Set-Content -path "$PSScriptRoot\..\02-Subscriptions\subscriptions-managementGroups.parameters.json"
