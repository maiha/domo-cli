#!/usr/bin/env bash

set -eu
for helper in $(dirname $0)/helpers/*; do source $helper; done

######################################################################
### domo-cli dataset create -f meta.json (test by dryrun)

describe "domo-cli dataset create -f meta.json"
it "POST meta.json to https://api.domo.com/v1/datasets with bearer token"
  rm -rf .domo && mkdir .domo
  create_token "abc"
  create_meta_json
  run  ./domo-cli dataset create -f meta.json -l log -v -n
  cp run.out cmd
  # access with bearer token
  run  grep "Authorization: bearer" cmd
  run  grep " -X POST" cmd
  run  grep " --data-binary @meta.json" cmd
  run  grep "https://api.domo.com/v1/datasets " cmd

it "(no access_token) # => ERROR"
  echo "{}" > .domo/token.out
  expect_error  ./domo-cli dataset create -f meta.json -l log -v -n
  run  grep "DOMO_CLIENT_ID" run.err.0

it "(no access_token, but ARGs given) # => first authorize, then access"
  echo "{}" > .domo/token.out
  run  ./domo-cli dataset create -f meta.json --client-id foo --client-secret bar -l log -v -n
  cp run.out cmd
  # authorize
  run  grep " -u 'foo:bar'" cmd
  run  grep "https://api.domo.com/oauth/token" cmd
  # access with bearer token
  run  grep "Authorization: bearer" cmd
  run  grep " -X POST" cmd
  run  grep " --data-binary @meta.json" cmd
  run  grep "https://api.domo.com/v1/datasets " cmd
