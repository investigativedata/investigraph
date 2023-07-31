# Command line

## Run a pipeline

### From local config

    investigraph run -c ./path/to/config.yml

### From a prefect block

    investigraph run -b github/my-datasets -d <dataset>

### Options

Where to output dataset metadata:

    --index-uri <uri>

Where to output entities:

    --entities-uri <uri>

Where to output (intermediate) entity fragments:

    --fragments-uri <uri>

Disable aggregation:

    --no-aggregate

Adjust chunk size (default: 1000)

    --chunk-size 10000

## Add a prefect block

[See prefect.io documentation](https://docs.prefect.io/latest/concepts/blocks/)

### local filesystem

    investigraph add-block -b local-file-system/<block-name> -u ./path/to/datasets

### github

    investigraph add-block -b github/<block-name> -u https://github.com/<user|organization>/<repo>.git

## Build deployment

[See prefect.io documentation](https://docs.prefect.io/latest/concepts/deployments/)

    prefect deployment build investigraph.pipeline:run -n investigraph-local --apply

## Inspect dataset configurations

[See tutorial](../tutorial.md)

    investigraph inspect ./path/to/config.yml

    investigraph inspect ./path/to/config.yml --extract

    investigraph inspect ./path/to/config.yml --transform

## Build a catalog

Build a catalog from datasets metadata and write it to anywhere from stdout (default) to any uri `fsspec` can handle, e.g.:

    investigraph build-catalog catalog.yml -u s3://mybucket/catalog.json

## Reset local prefect data

This will purge everything in `PREFECT_HOME`

    investigraph reset
