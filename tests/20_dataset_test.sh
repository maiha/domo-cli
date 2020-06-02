#!/usr/bin/env bash

set -eu
for helper in $(dirname $0)/helpers/*; do source $helper; done

######################################################################
### domo-cli dataset create -f meta.json (test by dryrun)

describe "domo-cli dataset create -f meta.json"
it "POST meta.json to https://api.domo.com/v1/datasets with bearer token"
  clean_outdir
  create_token "abc"
  create_meta_json
  run  ./domo-cli dataset create -f meta.json -l log -v -n
  cp run.out cmd
  # access with bearer token
  run  grep " -X POST" cmd
  run  grep " --data-binary @meta.json" cmd
  run  grep "Authorization: bearer" cmd
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
  run  grep " -X POST" cmd
  run  grep " --data-binary @meta.json" cmd
  run  grep "Authorization: bearer" cmd
  run  grep "https://api.domo.com/v1/datasets " cmd

######################################################################
### domo-cli dataset import <DATASET_ID> -f data.csv (test by dryrun)

describe "domo-cli dataset import <DATASET_ID> -f <DATA_CSV>"
it "PUT data.csv to https://api.domo.com/v1/datasets with bearer token"
  clean_outdir
  create_token "abc"
  create_meta_json
  run  ./domo-cli dataset import 123456 -f data.csv -l log -v -n
  cp run.out cmd
  # access with bearer token
  run  grep " -X PUT" cmd
  run  grep " --data-binary @data.csv" cmd
  run  grep "Content-Type: text/csv" cmd
  run  grep "Authorization: bearer" cmd
  run  grep "https://api.domo.com/v1/datasets/123456/data " cmd

it "(missinig DATASET_ID) # => ERROR"
  expect_error  ./domo-cli dataset import "" -f data.csv -l log -v -n
  run  grep "DATASET_ID" run.err.0

it "(no access_token) # => ERROR"
  echo "{}" > .domo/token.out
  expect_error  ./domo-cli dataset import 123456 -f data.csv -l domo/log -v -n
  run  grep "DOMO_CLIENT_ID" run.err.0

it "(no access_token, but ARGs given) # => first authorize, then access"
  echo "{}" > .domo/token.out
  run  ./domo-cli dataset import 123456 -f data.csv --client-id foo --client-secret bar -l log -v -n
  cp run.out cmd
  # authorize
  run  grep " -u 'foo:bar'" cmd
  run  grep "https://api.domo.com/oauth/token" cmd
  # access with bearer token
  run  grep " -X PUT" cmd
  run  grep " --data-binary @data.csv" cmd
  run  grep "Content-Type: text/csv" cmd
  run  grep "Authorization: bearer" cmd
  run  grep "https://api.domo.com/v1/datasets/123456/data " cmd

######################################################################
### domo-cli dataset update (test by dryrun)

describe "domo-cli dataset update <DATASET_ID> -f <META_JSON>"
it "PUT meta.json to https://api.domo.com/v1/datasets/<DATASET_ID> with bearer token"
  clean_outdir
  create_token "abc"
  create_meta_json
  run  ./domo-cli dataset update 123456 -f meta.json -l log -v -n
  cp run.out cmd
  # access with bearer token
  run  grep " -X PUT" cmd
  run  grep " --data-binary @meta.json" cmd
  run  grep "Content-Type: application/json" cmd
  run  grep "Authorization: bearer" cmd
  run  grep "https://api.domo.com/v1/datasets/123456 " cmd

it "(no DATASET_ID) # => ERROR"
  expect_error  ./domo-cli dataset update "" -f meta.json -l log -v -n
  run  grep "DATASET_ID" run.err.0

it "(no access_token) # => ERROR"
  echo "{}" > .domo/token.out
  expect_error  ./domo-cli dataset create -f meta.json -l log -v -n
  run  grep "DOMO_CLIENT_ID" run.err.0

it "(no access_token, but ARGs given) # => first authorize, then access"
  echo "{}" > .domo/token.out
  run  ./domo-cli dataset update 123456 -f meta.json --client-id foo --client-secret bar -l log -v -n
  cp run.out cmd
  # authorize
  run  grep " -u 'foo:bar'" cmd
  run  grep "https://api.domo.com/oauth/token" cmd
  # access with bearer token
  run  grep " -X PUT" cmd
  run  grep " --data-binary @meta.json" cmd
  run  grep "Content-Type: application/json" cmd
  run  grep "Authorization: bearer" cmd
  run  grep "https://api.domo.com/v1/datasets/123456 " cmd

######################################################################
### domo-cli dataset delete (test by dryrun)

describe "domo-cli dataset delete <DATASET_ID>"
it "DELETE https://api.domo.com/v1/datasets/<DATASET_ID> with bearer token"
  clean_outdir
  create_token "abc"
  run  ./domo-cli dataset delete 123456 -n
  cp run.out cmd
  run  grep " -X DELETE" cmd
  run  grep "Authorization: bearer" cmd
  run  grep "https://api.domo.com/v1/datasets/123456 " cmd

it "(no DATASET_ID) # => ERROR"
  expect_error  ./domo-cli dataset delete "" -l log -v -n
  run  grep "DATASET_ID" run.err.0

it "(no access_token) # => ERROR"
  echo "{}" > .domo/token.out
  expect_error  ./domo-cli dataset delete 123456 -l log -v -n
  run  grep "DOMO_CLIENT_ID" run.err.0

it "(no access_token, but ARGs given) # => first authorize, then access"
  echo "{}" > .domo/token.out
  run  ./domo-cli dataset delete 123456 --client-id foo --client-secret bar -l log -v -n
  cp run.out cmd
  # authorize
  run  grep " -u 'foo:bar'" cmd
  run  grep "https://api.domo.com/oauth/token" cmd
  # access with bearer token
  run  grep " -X DELETE" cmd
  run  grep "Authorization: bearer" cmd
  run  grep "https://api.domo.com/v1/datasets/123456 " cmd

######################################################################
### domo-cli dataset list (test by dryrun)

describe "domo-cli dataset list -f <DATA_CSV>"
it "GET https://api.domo.com/v1/datasets"
  clean_outdir
  create_token "abc"
  create_meta_json
  run  ./domo-cli dataset list -l log -v -n
  cp run.out cmd
  # access with bearer token
  run  grep "Authorization: bearer" cmd
  run  grep "https://api.domo.com/v1/datasets " cmd
