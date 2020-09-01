<#

clean-up script, very destructive

#>

param(
    [string] [Parameter(mandatory = $true)]$root
)

Write-Host "Removing Sets..."
#Get-AzPolicySetDefinition -ManagementGroupName $root | where-object{$_.properties.policytype -eq "custom"} | Remove-AzPolicySetDefinition -Force -verbose
Write-Host "Removing Definitions..."
#Get-AzPolicyDefinition -ManagementGroupName $root | where-object{$_.properties.policytype -eq "custom"} | Remove-AzPolicyDefinition -Force -verbose


# function to recurse the managementGroup heirarchy
function Kill-Children($parent, $id, $children){

    Write-Host "Group: $id"
    
    foreach($c in $children){
        Kill-Children $($id.Split('/')[-1]) $c.id $c.children
    }
    # if we have subscriptions, need to check the type/id and use the Remove-AzManangementGroupSubscription cmd
    if($id -like "/subscriptions*"){
        Write-Host "Removing Sub... $parent$id"
        Remove-AzManagementGroupSubscription -GroupName $parent -subscriptionId $($id.Split('/')[-1]) -verbose
    }else{
        Write-Host "Removing MG... $id"
        Remove-AzManagementGroup -GroupName $($id.Split('/')[-1]) -verbose
    }
}

# Get the top-level or root group
$mg = Get-AzManagementGroup -GroupName $root -Expand -Recurse

Write-Host "Removing MGs..."
Kill-Children $root $mg.id $mg.children
