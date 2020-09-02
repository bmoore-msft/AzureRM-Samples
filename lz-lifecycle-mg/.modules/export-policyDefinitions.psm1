function Get-PolicyDefinitionObject {

    <#
    .Synopsis
        Retrieve the hashtable (must then ConvertTo-JSON) need for the parameter file for the given policy definition.
    .Description
    .Notes
    #>

param(
    [Parameter(mandatory = $true)]$policyDefinition
)

    $p = $policyDefinition

    Write-Host "Exporting Policy Def: $($p.ResourceName)"

    # if this is a subscription level definition, the resourceId has a different format (subsriptionId property is also not $null)
    if($p.ResourceId -like '/subscriptions/*'){
        $scope = ($p.ResourceId).split('/')[2] # note, scope property in ARM does not work for anything but an extension resource, for this to work resulting deployment would have to be nested
    }else{
        $scope = ($p.ResourceId).split('/providers/')[1]
    }

    # remove metadata property - remove policyType so we can convert from enum to string (and then add it back)
    $md = $p.properties.metadata | Select-object -property * -ExcludeProperty createdBy, createdOn, updatedBy, updatedOn
    $q = $p.properties | Select-object -property * -ExcludeProperty metadata, policytype 
    $q | Add-member -MemberType NoteProperty -Name policyType -value "Custom"
    if((get-member -MemberType NoteProperty -InputObject $md) -ne $null){
        $q | Add-Member -MemberType NoteProperty -Name 'metadata' -Value $md
    }

    $json = [ordered]@{
        name = $p.ResourceName
        properties = $q #$p.properties
    }
    
    $ParamFile = [ordered]@{
        '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
        contentVersion = "1.0.0.0"
        parameters = @{
            policyDefinition = @{
                value = $json
            }
        }
    }

return $ParamFile

}
