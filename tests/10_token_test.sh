#!/usr/bin/env bash

set -eu
for helper in $(dirname $0)/helpers/*; do source $helper; done

######################################################################
### domo-cli token

describe "domo-cli token show"
it "(file exists) # => inspect the token"
  create_token "abc"
  run  ./domo-cli token show
  run  grep 'token.*abc' run.out.0

it "(no files) # => ERROR"
  rm -f .domo/token.out
  expect_error  ./domo-cli token show
  run  grep 'The token file does not exist' run.err.0

######################################################################
### domo-cli token authorize (test by dryrun)

describe "domo-cli token authorize"
it "(no env: DOMO_CLIENT_SECRET) # => ERROR"
  export DOMO_CLIENT_ID=foo
  unset DOMO_CLIENT_SECRET
  expect_error  ./domo-cli token authorize -n -l log -v
  run  grep 'DOMO_CLIENT_SECRET' run.err.0

it "(give ENVs) # => call https://api.domo.com/oauth/token with -u foo:bar"
  export DOMO_CLIENT_ID=foo
  export DOMO_CLIENT_SECRET=bar
  run  ./domo-cli token authorize -n -l log -v
  cp run.out cmd
  run  grep "chmod 700 .domo" cmd
  run  grep " -u 'foo:bar'" cmd
  run  grep "https://api.domo.com/oauth/token" cmd
  run  grep "grant_type=client_credentials&scope=data" cmd

it "(give ARGs) # => call https://api.domo.com/oauth/token with -u foo:bar"
  unset DOMO_CLIENT_ID
  unset DOMO_CLIENT_SECRET
  run  ./domo-cli token authorize --client-id=foo --client-secret=bar -n -l log -v
  cp run.out cmd
  run  grep " -u 'foo:bar'" cmd
  run  grep "https://api.domo.com/oauth/token" cmd
  run  grep "grant_type=client_credentials&scope=data" cmd

######################################################################
### cached token client_id validation

describe "domo-cli (cached client_id validation)"
it "(cached matches given client_id) # => reuse cached token, no re-authorize"
  clean_outdir
  create_token_with_client_id "abc" "foo"
  run  ./domo-cli dataset list --client-id=foo --client-secret=bar -n
  cp run.out cmd
  expect_error  grep "oauth/token" cmd

it "(cached mismatches given client_id) # => re-authorize with new credentials"
  clean_outdir
  create_token_with_client_id "abc" "foo"
  run  ./domo-cli dataset list --client-id=baz --client-secret=qux -n
  cp run.out cmd
  run  grep "https://api.domo.com/oauth/token" cmd
  run  grep " -u 'baz:qux'" cmd

it "(cached has no client_id) # => re-authorize"
  clean_outdir
  create_token "abc"
  run  ./domo-cli dataset list --client-id=foo --client-secret=bar -n
  cp run.out cmd
  run  grep "https://api.domo.com/oauth/token" cmd
