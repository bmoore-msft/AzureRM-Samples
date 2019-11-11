<#
Creates and AAD Application and Service Principal
#>

param(
[string] [Parameter(Mandatory=$true)]$DisplayName,
[string] [Parameter(Mandatory=$true)]$HomePage,
[string] [Parameter(Mandatory=$true)]$Password
)

#Check if app already exists
$app = Get-AzureRmADApplication -DisplayName $DisplayName

if($app -eq $null){
    Write-Host "Creating App..."
    $app = New-AzureRmADApplication -DisplayName $DisplayName `
                                    -HomePage $HomePage `
                                    -IdentifierUris $HomePage `
                                    -Password $(ConvertTo-SecureString $Password -AsPlainText -force)
}

#Check if SP already exists
$sp = Get-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId
if($sp -eq $null){
    Write-Host "Creating SP..."
    $sp = New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId
}

Write-Host $sp.ApplicationId
Write-Host "##vso[task.setvariable variable=appId]$($sp.ApplicationId)"
