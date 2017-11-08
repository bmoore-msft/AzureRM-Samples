# KeyVault with a Dynamic reference

This sample shows:
- How to use a KeyVault parameter reference that is constructed during deployment rather than put into a parameter file prior to deployment
- How to use PowerShell or the CLI to "stage" artifacts into Azure storage for deployment
    - So you don't have to use a public github url


In practice, the deployment that consumes the secret would need to be nested in order to keep the secret secure throughout all deployments.  SecureStrings cannot be passed between deployments in the outputs.
    
`Note: Currently this approach requires using a linked template, it doesn't work when using an inline template (8 November 2017)`

