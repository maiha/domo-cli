DOMO_CLI=./domo-cli

function clean_outdir() {
  rm -rf .domo && mkdir .domo
}

function create_token() {
  local v=$1
  mkdir -p .domo
  cat <<EOF > .domo/token.out
{"access_token":"$v","expires_in":3600}
EOF
}

function create_token_with_client_id() {
  local v=$1
  local cid=$2
  mkdir -p .domo
  cat <<EOF > .domo/token.out
{"access_token":"$v","expires_in":3600,"client_id":"$cid"}
EOF
}

function create_meta_json() {
  cat <<'EOF' > meta.json
{
  "name": "domo-cli (test)",
  "description": "https://github.com/maiha/domo-cli",
  "schema": {"columns": [{"type":"STRING","name":"key"},{"type":"STRING","name":"val"}]}
}
EOF
}
