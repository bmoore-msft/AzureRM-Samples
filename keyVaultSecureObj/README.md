# KeyVault Using a SecureObject

This sample has 2 parts:

1. Adds 50 secrets to a vault using a json string inside a single secret
1. Deploys a sample template using that json string as a way to get 50 secrets back from the vault as a secure object

Deploy the KeyVaultAddSecureObj.json and then use the resourceId from that vault in the KeyVaultUseSecureObj.json deployment.
