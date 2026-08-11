# ADO auth — fluidframework/internal (FluidFramework codespaces)

Agents CAN authenticate to Azure DevOps here. NEVER say "cannot authenticate to ADO".

## Mint a token (short-lived ~1h; re-run each time it expires)
```
export AZURE_DEVOPS_EXT_PAT=$(azureauth ado token --output token 2>/dev/null)
```
- Binary: `/usr/bin/azureauth` (already signed in via MSAL cache). The `~/ado-auth-helper`
  wrapper may be ABSENT in this repo's codespace — call `azureauth` directly.
- Token is an AAD JWT; both REST (`curl -u :"$TOKEN"`) and `az` accept it in the PAT slot.
- If token comes back empty: the helper/cache isn't set up; don't fall back to "can't auth".

## Org / project
- org: `https://dev.azure.com/fluidframework`  •  project: `internal`
- SharedTree area path: `internal\Team Taylor\SharedTree`

## REST (no `az` CLI installed here — use curl)
Base: `https://dev.azure.com/fluidframework/internal/_apis`  •  auth `curl -u :"$AZURE_DEVOPS_EXT_PAT"`
- Read WI:  `GET  .../wit/workitems/<id>?api-version=7.1`
- Create:   `POST .../wit/workitems/$<Type>?api-version=7.1` (e.g. `$Task`),
            header `Content-Type: application/json-patch+json`,
            body `[{"op":"add","path":"/fields/System.Title","value":"..."}, ...]`
- Update:   `PATCH .../wit/workitems/<id>?api-version=7.1` with `"op":"replace"`.
- `System.Description` is HTML. Set `System.AreaPath` (backslashes escaped `\\`).

## Gotchas
- `az account show` FAILS ("run az login") — ARM login isn't set up; the token path still
  works for boards/repos. Not a sign auth is broken.
- Parse REST JSON with `node -e` or `jq` (python3 json module missing once).
- ADO text: never reference GitHub issues/PRs as bare `#n` / `AB#n` (auto-links to internal
  ADO). Use full github.com URLs.
- The same `azureauth` token also works against the `office` org
  (`https://office.visualstudio.com`, project `OC`) to read office-bohemia items.
