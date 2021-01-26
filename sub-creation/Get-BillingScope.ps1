# Get all the billing scopes a the logged in user has access to

$json = @{}

$billingAccounts = Get-AzBillingAccount -debug

foreach ($ba in $billingAccounts) {
    Write-Host "Billing Account: $($ba.name)"
    
    $billingProfiles = Get-AzBillingProfile -BillingAccountName $ba.name -debug
    
    foreach($bp in $billingProfiles){
        Write-Host "    Billing Profile: $($bp.name)"
        
        $invoiceSections = Get-AzInvoiceSection -BillingAccountName $ba.name -BillingProfileName $bp.name -debug
        
        foreach($is in $invoiceSections){
            Write-Host "        InvoiceSection: $($is.name)"
            $json = [ordered]@{
                billingAccountName = @{
                    value = $ba.name
                }
                billingProfileName = @{
                    value = $bp.name
                }
                invoiceSectionName = @{
                    value = $is.name
                }
            }
            $json | ConvertTo-Json
        }
    }
}

<#
"billingProfile": {
    "value": "" 
},
"billingAccount": {
    "value": "" 
},
"invoiceSection": {
    "value": "" 
},
#>