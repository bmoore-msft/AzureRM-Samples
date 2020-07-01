# Generate a Password In A Template

In a template deployment the newGuid() function can be used to generate a guid.  This guid is random and will not be idempotent - a new guid is generated each time the template is deployed.  This guid can be used in password generation in a few ways:

- the GUID can be used directly as a password, it's 32 chars but may not meet some password requirements
- a simple variation, use the guid but add some static chars to meet complexity requirements like symbols - if the same chars are used this isn't really any more secure than the guid itself but works well for complexity requirements
- final variation uses a character map to replace certain chars in the guid - see the template

The approach is straight forward, you can use params to make things more secure, could add more rules (like a min number of symbol chars) etc.

Final note, never put a secret in the output section of a template - outputs are available to anyone with read permission over the deployment's scope.
