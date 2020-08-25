
param(
    [string] [Parameter(mandatory = $true)]$root
)

function Get-Children($id, $children, [array]$output){

    Write-Host "Handling: $id"
    
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

$mg = Get-AzManagementGroup -GroupName $root -Expand -Recurse

$output = @([ordered]@{})

$output = Get-Children $mg.id $mg.children $output

$output = $output += @{
    name = 'bmoore-mgmt-group'
    displayName = $mg.displayName
    parentName = ""
}

#reverse the array, because sequence matters for the loop and improves readability in the template
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

$mgParamFile = @{
    '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
    contentVersion = "1.0.0.0"
    parameters = @{
        groups = @{
            value = $mgs
        }
    }
}

$subParamFile = @{
    '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
    contentVersion = "1.0.0.0"
    parameters = @{
        subscriptions = @{
            value = $subs
        }
    }
}

$mgTemplateFile = @{}

$mgParamFile | ConvertTo-Json -Depth 30 | Set-Content -path ".\groups.loop.parameters.json" 
$subParamFile | ConvertTo-Json -Depth 30 | Set-Content -path ".\subs-groups.loop.parameters.json"

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

$mgTemplate = @{
    '$schema' =  "https://schema.management.azure.com/schemas/2019-08-01/tenantDeploymentTemplate.json#"
    contentVersion = "1.0.0.0"
    resources = $resources
}

$mgTemplate | ConvertTo-Json -Depth 30 | Set-Content -path ".\groups.json" 
