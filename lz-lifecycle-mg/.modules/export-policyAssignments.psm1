function Get-PolicyAssignmentObject {

    <#
    .Synopsis
        Retrieve the hashtable (must then ConvertTo-JSON) need for the parameter file for the given policy assignment
    .Description
    .Notes
    #>

param(
    [Parameter(mandatory = $true)]$policyAssignment
)

    $a = $policyAssignment

    Write-Host "Exporting Policy Assignment: $($a.ResourceName)"

    # if this is a subscription level definition, the resourceId has a different format (subsriptionId property is also not $null)
    if($a.ResourceId -like '/subscriptions/*'){
        $scope = ($a.ResourceId).split('/')[2] # note, scope property in ARM does not work for anything but an extension resource, for this to work resulting deployment would have to be nested
    }else{
        $scope = ($a.ResourceId).split('/providers/')[1]
    }

    # remove metadata property - but only remove the audit metadata in case user added something custom
    $md = $a.properties.metadata | Select-object -property * -ExcludeProperty createdBy, createdOn, updatedBy, updatedOn
    $q = $a.properties | Select-object -property * -ExcludeProperty metadata, EnforcementMode
    if($a.properties.EnforcementMode -eq 0){
        $enforcementMode = "Default"
    }else{
        $enforcementMode = "DoNotEnforce"
    }
    $q | Add-member -MemberType NoteProperty -Name enforcementMode -value $enforcementMode
    if((get-member -MemberType NoteProperty -InputObject $md) -ne $null){
        $q | Add-Member -MemberType NoteProperty -Name 'metadata' -Value $md
    }

    $json = [ordered]@{
        name = $a.ResourceName
        identity = $a.identity | Select-Object -property * -ExcludeProperty principalId, tenantId
        location = $a.location
        properties = $q #$a.properties
    }
    
    $ParamFile = [ordered]@{
        '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
        contentVersion = "1.0.0.0"
        parameters = @{
            policyAssignment = @{
                value = $json
            }
        }
    }

    return $ParamFile

}
