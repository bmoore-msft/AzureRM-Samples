<#
Export all policyAssignments under the specified root
#>

param(
    [string] [Parameter(mandatory = $true)]$root
)

# function to recurse the managementGroup heirarchy
function Get-Children($id, $children, [array]$output){
    Write-Host "Found Group: $id"
    foreach($c in $children){
        Get-Children $c.id $c.children $output
    }
    $output = $output += $id
    return $output
}

$output = @()

# Get the top-level or root group for export
$mg = Get-AzManagementGroup -GroupName $root -Expand -Recurse

# build an array of all the mgs in the hierarchy
$output = Get-Children $mg.id $mg.children $output

# now retrieve the assignments for each scope in the array
$assignments = @()
$policyList = @()

foreach($scope in $output){
    Write-Host "Checking Scope for assignments: $scope"
    $a = Get-AzPolicyAssignment -Scope "$scope"
    $assignments += $a
}

# Remove the duplicate objects from the list of all assignments (from inherited assignments)
$assignments = $assignments | Sort-Object -Property ResourceId -Unique

foreach($a in $assignments){
    
    Write-Host "Exporting: $($a.ResourceName)"

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

    # don't add it if it's empty after we remove the "auto" properites
    if((get-member -MemberType NoteProperty -InputObject $md) -ne $null){
        $q | Add-Member -MemberType NoteProperty -Name 'metadata' -Value $md
    }

    $json = [ordered]@{
        name = $a.ResourceName
        deploymentScope = $scope
        identity = $a.identity | Select-Object -property * -ExcludeProperty principalId, tenantId
        location = $a.location
        properties = $q #$a.properties
    }

    $filePath = "$PSScriptRoot\policyAssignments\$($a.ResourceName).parameters.json"
    
    $ParamFile = [ordered]@{
        '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
        contentVersion = "1.0.0.0"
        parameters = @{
            policyAssignment = @{
                value = $json
            }
        }
    }

    $ParamFile | ConvertTo-Json -Depth 50 | Set-Content -path $filePath 

    $policyList += $a.ResourceName

}

# write the main template's parameter file to include the list of definitions
$ParamFile = [ordered]@{
    '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
    contentVersion = "1.0.0.0"
    parameters = @{
        policyAssignments = @{
            value = $policyList
        }
    }
}

$ParamFile.Parameters | ConvertTo-Json -Depth 20 | Set-Content -path "$PSScriptRoot\policyAssignments.parameters.json" 
