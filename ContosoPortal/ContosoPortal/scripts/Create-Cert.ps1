param(

[string] [Parameter(Mandatory=$false)] $vaultName,
[string] [Parameter(Mandatory=$false)] $certificateName,
[string] [Parameter(Mandatory=$false)] $subjectName

)

$policy = New-AzureKeyVaultCertificatePolicy -SubjectName $subjectName -IssuerName Self -ValidityInMonths 12 -Verbose
Add-AzureKeyVaultCertificate -VaultName $vaultName -Name $certificateName -CertificatePolicy $policy -Verbose

#private key is added as a secret that can be retrieved in the ARM template
