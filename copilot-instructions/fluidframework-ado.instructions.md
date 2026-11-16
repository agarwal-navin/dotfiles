---
applyTo: '**'
---
# FluidFramework Codespace authentication

These instructions apply only when the current workspace is FluidFramework.
At the start of the session, read `~/.copilot/reference/FluidFramework/ado-auth.md` before answering the first request.
If `COPILOT_HOME` is set, use `$COPILOT_HOME/reference/FluidFramework/ado-auth.md` instead.

For ADO access, first try `/usr/bin/azureauth ado token --output token` and capture the token privately.
This method can use an existing authentication cache without an Azure CLI login or a browser sign-in.
An Azure CLI "run az login" error does not establish that ADO authentication is unavailable.
Verify access with a read-only request to the required ADO endpoint before reporting success.
If token acquisition fails, report the actual failure rather than assuming that a browser or device-code sign-in is required.

Never print tokens, write them to files, or include them in chat.
