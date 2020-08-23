
function Get-Children($id, $children){

    Write-Host "Handling: $id"
    
    foreach($c in $children){
        Get-Children $c.id $c.children
        
        # if this is not a subscription, create the value - subscriptions have a different lifecycle so are not in the same template
        if($c.type -like "*/managementGroups"){
            $param = [ordered]@{
                name = $c.name
                displayName = $c.displayName
                parentName = $id.Split("/")[-1] # name is the last segment of the resourceId
            }
            $param | ConvertTo-Json | Add-Content -path ".\mg.dump.json"
        }else{
            $param = [ordered]@{
                displayName = $c.displayName
                subscription = $c.name
                parentName = $id.Split("/")[-1]
            }
            $param | ConvertTo-Json | Add-Content -path ".\subs.dump.json"
        }
    }
}

$mg = Get-AzManagementGroup -GroupName 'bmoore-mgmt-group' -Expand -Recurse

Get-Children $mg.id $mg.children

