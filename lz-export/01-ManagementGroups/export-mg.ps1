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
                name = $c.name
                displayName = $c.displayName
                parentName = $id.Split("/")[-1] # name is the last segment of the resourceId
            }
        }else{
            $param = [ordered]@{
                displayName = $c.displayName
                subscription = $c.name
                parentName = $id.Split("/")[-1]
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
$output = $output += @{
    name = $root
    displayName = $mg.displayName
    parentName = ""
}

# reverse the array, because sequence matters for the loop and improves readability in the template
$orderedOutput = [array]::Reverse($output)

# Separate the MG and the Subscriptions as they have different lifecycles and need different files
$mgs = @()
$subs = @()

foreach($item in $output){
    if($item.Contains('subscription')){
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
            value = $mgs
        }
    }
}

# Create the param file for the subscription template
$subParamFile = [ordered]@{
    '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
    contentVersion = "1.0.0.0"
    parameters = @{
        subscriptions = @{
            value = $subs
        }
    }
}

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

# Write the files
$mgTemplate | ConvertTo-Json -Depth 30 | Set-Content -path ".\managementGroups.json" 
$mgParamFile | ConvertTo-Json -Depth 30 | Set-Content -path ".\managementGroups.loop.parameters.json" 
$subParamFile | ConvertTo-Json -Depth 30 | Set-Content -path ".\subscriptions-managementGroups.loop.parameters.json"
