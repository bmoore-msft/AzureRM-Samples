<#
Export all policyDefinitions under the specified mg
#>

param(
    [string] [Parameter(mandatory = $true)]$root
)

# Only get Custom policyDefinitions
$defs = Get-AzPolicySetDefinition | Where-Object{$_.Properties.PolicyType -eq "custom"}

$policyList = @()

foreach($p in $defs){
    
    Write-Host "Exporting: $($p.ResourceName)"

    $json = @{}

    # if this is a subscription level definition, the resourceId has a different format (subsriptionId property is also not $null)
    if($p.ResourceId -like '/subscriptions/*'){
        $scope = ($p.ResourceId).split('/')[2] # note, scope property in ARM does not work for anything but an extension resource, for this to work resulting deployment would have to be nested
    }else{
        $scope = ($p.ResourceId).split('/providers/')[1]
    }

    # remove metadata property - remove policyType so we can convert from enum to string (and then add it back)
    $md = $p.properties.metadata | Select-object -property * -ExcludeProperty createdBy, createdOn, updatedBy, updatedOn
    $q = $p.properties | Select-object -property * -ExcludeProperty metadata, policytype, PolicyDefinitions.policyDefinitionReferenceId 
    $q | Add-member -MemberType NoteProperty -Name policyType -value "Custom"
    if((get-member -MemberType NoteProperty -InputObject $md) -ne $null){
        $q | Add-Member -MemberType NoteProperty -Name 'metadata' -Value $md
    }
    $json = @{
        scope = $scope
        name = $p.ResourceName
        properties = $q #$p.properties
    }

    $filePath = "$PSScriptRoot\policySetDefinitions\$($p.ResourceName).parameters.json"
    
    $ParamFile = [ordered]@{
        '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
        contentVersion = "1.0.0.0"
        parameters = @{
            policySetDefinition = @{
                value = $json
            }
        }
    }

    $ParamFile | ConvertTo-Json -Depth 50 | Set-Content -path $filePath 

    $policyList += $p.ResourceName

}

# write the main template's parameter file to include the list of definitions
$mainParamFile = [ordered]@{
    '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
    contentVersion = "1.0.0.0"
    parameters = @{
        policySetDefinitions = @{
            value = $policyList
        }
    }
}

$mainParamFile.Parameters | ConvertTo-Json -Depth 20 | Set-Content -path "$PSScriptRoot\policySetDefinitions.parameters.json" 
