function Get-PolicySetDefinitionObject {

    <#
    .Synopsis
        Retrieve the hashtable (must then ConvertTo-JSON) needed for the parameter file for the given policy set.
    .Description
    .Notes
    #>

param(
    [Parameter(mandatory = $true)]$policySetDefinition
)

    $p = $policySetDefinition
    
    Write-Host "Exporting Policy Set: $($p.ResourceName)"

    # if this is a subscription level definition, the resourceId has a different format (subsriptionId property is also not $null)
    if($p.ResourceId -like '/subscriptions/*'){
        $scope = ($p.ResourceId).split('/')[2] # note, scope property in ARM does not work for anything but an extension resource, for this to work resulting deployment would have to be nested
    }else{
        $scope = ($p.ResourceId).split('/providers/')[1]
    }

    # remove metadata property - remove policyType so we can convert from enum to string (and then add it back)
    $md = $p.properties.metadata | Select-object -property * -ExcludeProperty createdBy, createdOn, updatedBy, updatedOn
    # Remove the policyDefinitionReferenceId property from each policyDef item in the array
    $pdArray = @()
    foreach($x in $p.properties.PolicyDefinitions){ 
        $pdArray += $x | Select-Object -property * -ExcludeProperty policyDefinitionReferenceId
    }
    # reconstruct the properties object after remomving extraneous properties
    $q = $p.properties | Select-object -property * -ExcludeProperty metadata, policytype, PolicyDefinitions #.policyDefinitionReferenceId 
    $q | Add-Member -MemberType NoteProperty -Name policyDefinitions -value $pdArray
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
            policySetDefinition = @{
                value = $json
            }
        }
    }

    return $ParamFile

}
