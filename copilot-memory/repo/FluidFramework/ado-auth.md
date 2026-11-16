# ADO auth — fluidframework/internal (FluidFramework codespaces)

Agents can authenticate to Azure DevOps through AzureAuth when the current process can use an existing cached sign-in.
Check this method before concluding that authenticated ADO access is unavailable.
Installing the executable alone does not provide the same cached authentication as a working terminal.

## Acquire a token from the existing cache

Use the exact command `/usr/bin/azureauth ado token --output token`.
Capture stdout privately in process memory, for example with Node.js `execFileSync` and piped stdout.
Do not run the command with stdout connected to the terminal or tool output.
Never print the token, write it to a file, export it as an environment variable, or include it in command-line arguments.
Capture error output privately too, and remove authentication data before reporting an error.

This command can return a usable token without interactive sign-in.
Call `/usr/bin/azureauth` directly; the optional `~/ado-auth-helper` wrapper is not required.
The token is a short-lived AAD JWT. Acquire another token when it expires.

## Verify access with a read-only request

Keep the captured token in the same process and send it as the `Authorization: Bearer <token>` header.
For example, use Node.js `fetch` to make this request:

```text
GET https://dev.azure.com/fluidframework/_apis/projects/internal?api-version=7.1
```

Confirm HTTP 200 and a project name of `internal`.
Token acquisition alone does not prove access to the intended organization and project.
If a resource request returns 404, also check that the resource belongs to the selected project.

## If token acquisition fails

Compare the agent process with the working terminal before attempting another login:

- Compare the OS user and `HOME`. Report whether they match, without printing environment-variable values.
- Check authentication-cache ownership and access permissions for that user.
  Do not print cache contents or credential files.
- If `/usr/bin/azureauth` is missing, report that separately from a sign-in or cache-access failure.
  Installing it alone does not restore cached authentication.
- A nonempty token and a successful ADO request are the verification steps.
  MSAL cache warnings alone do not prove that authentication failed.

Report failures explicitly, but do not expose tokens or authentication URLs.
Do not copy credentials or authentication caches from another Codespace or user.
Only request interactive sign-in after these checks show that the existing cached sign-in cannot be used.

## Org / project
- org: `https://dev.azure.com/fluidframework`  •  project: `internal`
- SharedTree area path: `internal\Team Taylor\SharedTree`

## REST (no Azure CLI required)

Base: `https://dev.azure.com/fluidframework/internal/_apis`.
Use the privately captured token in an authorization header, as described above.
- Read WI:  `GET  .../wit/workitems/<id>?api-version=7.1`
- Create:   `POST .../wit/workitems/$<Type>?api-version=7.1` (e.g. `$Task`),
            header `Content-Type: application/json-patch+json`,
            body `[{"op":"add","path":"/fields/System.Title","value":"..."}, ...]`
- Update:   `PATCH .../wit/workitems/<id>?api-version=7.1` with `"op":"replace"`.
- `System.Description` is HTML. Set `System.AreaPath` (backslashes escaped `\\`).

## Gotchas
- Do not use `az account show` as an ADO authentication check.
  It checks Azure Resource Manager, which is separate from Azure DevOps.
  Do not install Azure CLI as a workaround for ADO authentication.
- Parse REST JSON with `node -e` or `jq` (python3 json module missing once).
- ADO text: never reference GitHub issues/PRs as bare `#n` / `AB#n` (auto-links to internal
  ADO). Use full github.com URLs.
- The same `azureauth` token also works against the `office` org
  (`https://office.visualstudio.com`, project `OC`) to read office-bohemia items.
