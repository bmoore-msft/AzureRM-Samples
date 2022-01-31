<#
    .Synopsis
        This script will deploy an Azure Resource Manager Template using the "az rest" command to invoke the REST api directly
    .Description
        This script will deploy an Azure Resource Manager Template using the "az rest" command to invoke the REST api directly.

        It deploys at resourceGroup scope but can be easily modified for any scope of deployment.

        The current account context must already be selected before executing the script, use 'az account show' to show the context
#>

Param(
    [string] [Parameter(Mandatory = $true)]$Location,
    [string] $ScopeName, # resourceGroupName or managementGroupName
    [string] [Parameter(Mandatory = $true)]$TemplateFile,
    [string] $TemplateParametersFile,
    [string] $DeploymentName = "rest-" + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm'),
    [string] $mode = "incremental"
)

$TemplateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateFile))

$TemplateObj = Get-Content $TemplateFile -Raw | ConvertFrom-JSON
if (![string]::IsNullOrWhiteSpace($TemplateParametersFile)) {
    $TemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateParametersFile))
    $TemplateParametersObj = Get-Content $TemplateParametersFile -Raw | ConvertFrom-JSON
    if (($TemplateParametersObj | Get-Member -Type NoteProperty 'parameters') -ne $null) {
        $TemplateParametersObj = $TemplateParametersObj.parameters
    }
}
else {
    $TemplateParametersObj = @{ }
}

$subscriptionId = (Get-AzContext).Subscription.Id

$targetSchema = $TemplateObj.'$schema'

$targetScope = switch -Wildcard ($targetSchema) {
    "*tenantDeployment*" {""}
    "*subscription*"     {"/subscriptions/$subscriptionId"}
    "*managementGroup*"  {"/providers/Microsoft.Management/managementGroups/$scopeName"}
    default              {"/subscriptions/$subscriptionId/resourceGroups/$scopeName"} 
}

$body = @{
    properties = @{
        template   = $TemplateObj
        mode       = $mode
        parameters = $TemplateParametersObj
    }
}

if($targetScope -notlike "*/resourceGroups/*"){
    $body.location = $location
}

$bodyJSON = $body | ConvertTo-Json -Compress -Depth 30

$method = "PUT"

$uri = "$targetScope/providers/Microsoft.Resources/deployments/$($deploymentName)?api-version=2020-10-01"

Invoke-AzRestMethod -Method $method -Path $uri -Payload $bodyJSON -Debug

# wait for the deployment to reach a terminal state
do {
    Start-Sleep 5
    $status = (Invoke-AzRestMethod -Method "GET" -path $uri -Verbose).Content | ConvertFrom-Json
    Write-Host $status.properties.provisioningState
} while ($status.properties.provisioningState -eq "Running")

$status | ConvertTo-Json -Depth 30
