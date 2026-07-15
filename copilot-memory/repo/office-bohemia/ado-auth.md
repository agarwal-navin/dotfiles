# Azure DevOps auth in this codespace (office-bohemia)

Agents CAN authenticate to ADO here. Do NOT say "cannot authenticate" — use the
codespace ADO auth helper to mint a short-lived AAD token and pass it in the PAT
 slot.

## Get a token (short-lived, ~1h — re-run each time)
```bash
export AZURE_DEVOPS_EXT_PAT=$(~/ado-auth-helper get-access-token 499b84ac-1321-427f-aa17-267ca6975798/.default 2>/dev/null)
```
- `~/ado-auth-helper` (== `~/azure-auth-helper`) is dropped in by the `ado-codespaces-auth` extension, already signed in as the user.
- `499b84ac-1321-427f-aa17-267ca6975798` = Azure DevOps first-party app resource ID; `/.default` scope.
- Token is a JWT (`eyJ...`). Both `az` CLI (`AZURE_DEVOPS_EXT_PAT`) and REST (`curl -u :$TOKEN`) accept an AAD bearer token wherever a PAT is expected.
- NOT a persisted PAT; no static secret stored. Just re-run the helper when it expires.

## Org / project
- org: `https://office.visualstudio.com`  (org name `office`)
- project: `OC`   repo: `office-bohemia`

## Notes / gotchas
- `az account show` FAILS ("run az login") because ARM login isn't set up — that's fine; `az boards`/`az repos` work via the token above. Don't be misled into thinking auth is broken.
- `az boards work-item relation add` does NOT accept `--project` (only `--org`).
- GitKraken MCP azure tools require a separate connect flow (often not connected) — prefer the CLI + token path.
- python3 `json` module was missing once; use `node -e` or `jq` to parse REST JSON.

## Diagnostic (if unsure auth works)
```bash
which az
ls -la ~/ado-auth-helper ~/azure-auth-helper
~/azure-auth-helper get-access-token 499b84ac-1321-427f-aa17-267ca6975798/.default | head -c 20
```
All three succeed -> auth is fine (failures are permissions or bad command). Empty token/missing helper -> `ado-codespaces-auth` extension not installed/activated/signed-in.

## Create a bug + parent link
```bash
NEW_ID=$(az boards work-item create --org https://office.visualstudio.com --project OC \
  --type Bug --title "..." --description "<html/text>" --query id -o tsv)
az boards work-item relation add --id "$NEW_ID" --relation-type parent --target-id <FEATURE_ID> \
  --org https://office.visualstudio.com
```

## Create a PR + link work item
```bash
az repos pr create --org https://office.visualstudio.com --project OC --repository office-bohemia \
  --source-branch <branch> --target-branch master --title "..." --description "..." \
  --work-items <ID> --query pullRequestId -o tsv
```

## PR threads/comments/status via REST
Base: `https://office.visualstudio.com/OC/_apis/git/repositories/office-bohemia/pullRequests/<PRID>`
- List threads:  `GET  .../threads?api-version=7.1`  (parse with node/jq)
- Reply:         `POST .../threads/<threadId>/comments?api-version=7.1`  body `{"parentCommentId":1,"content":"...","commentType":"text"}`
- Resolve thread:`PATCH .../threads/<threadId>?api-version=7.1`  body `{"status":"fixed"}`  (statuses: active|fixed|wontFix|closed|pending|byDesign)
Use `curl -u :"$AZURE_DEVOPS_EXT_PAT"`.
