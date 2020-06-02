DOMO_CLI=./domo-cli

function create_token() {
  local v=$1
  mkdir -p .domo
  cat <<EOF > .domo/token.out
{"access_token":"$v","expires_in":3600}
EOF
}
