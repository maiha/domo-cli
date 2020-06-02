# domo-cli

The Domo Command Line Interface built as a static x86_64 binary.

```console
$ domo-cli import-dataset <dataset_id> --client-id <id> --client-secret <secret> -f <data.csv>
```

## Installation
* x86_64 static binary: https://github.com/maiha/domo-cli/releases

## OAuth 2.0
The Domo API uses OAuth 2.0 authentication. 
domo-cli accepts authentication information by environment variables or arguments.

```console
$ export DOMO_CLIENT_ID=foo
$ export DOMO_CLIENT_SECRET=bar
```

```console
$ domo-cli ... --client-id=foo --client-secret=bar
```

The following usages assume that credentials have been granted in one of the above ways.

## Usage

domo-cli is itself built as a RESTful design and executed with **RESOURCE** and **ACTION** as arguments.

### Dataset resource

* Available actions : **create**, **update**, **import**, **get**, **delete**

```console
$ domo-cli dataset import -f data.csv
```

### Token

Althoug domo-cli will automatically update OAuth tokens when it is expired,
you can manually update it by `token authorize`.

```console
$ domo-cli token authorize --client-id=<CLIENT_ID> --client-secret=<CLIENT_SECRET>
$ domo-cli token show
```

The token file is stored in `.domo` directory in default. See the **Outdir** for details.

### Outdir

Internally, domo-cli executes the API with a series of shell commands.
And it creates following files in the output directory.
* the authentication tokens
* history of executed shell commands
* intermediate files needed to execute the API
The directory can be specified with the "-C <DIR>" option, which defaults to `.domo`.

### Dryrun

domo-cli is a thin wrapper for cURL. It shows a cURL shell command by "-n" arg.

```console
$ domo-cli dataset get <dataset_id> -n
```

## Roadmap

## Development

* [Crystal](http://crystal-lang.org/).

```console
$ make compile
$ make test
```

## Contributing

1. Fork it (<https://github.com/maiha/domo-cli/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) - creator and maintainer
