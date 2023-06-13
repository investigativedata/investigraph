# Overview

**investigraph** is a framework to orchestrate data processing workflows that transform source data into [entities](../concepts/entity/).

This framework tries to automatize as many functionality (scheduling and executing workflows, monitoring, extracting and storing to various local or remote sources, configuration, ...) as possible with the help of [prefect.io](../stack/prefect/).

As **investigraph** can be considered as an [ETL-process](https://en.wikipedia.org/wiki/Extract,_transform,_load) for [Follow The Money data](../stack/followthemoney/), the structure (of the codebase and this overview documentation) roughly follows the three steps of such a pipeline: *extract, transform, load*.

The following documentation assumes you already checked out [the tutorial](../tutorial/). The documentation on this page covers the whole pipeline process more in depth. For a complete (technical) reference, check out [config.yml](./config/) and [parse.py](./parse).

Most of the running behaviour of a specific [pipeline](../concepts/pipeline) is configured on a per-[dataset](../concepts/dataset) basis and/or via arguments given to a specific run of the pipeline, either via the prefect ui or via command line.

## Extract

In the first step of a pipeline, we focus on getting one or more data sources and extracting data records from them that will eventually be passed to the [next stage](#transform).

### Source

A data source is defined by a `uri`. As investigraph is using [smart_open](https://github.com/RaRe-Technologies/smart_open) under the hood, this `uri` can be anything from a local file path to a remote s3 resource.

Examples for source uris:
```
s3://my_bucket/data.csv
s3://my_key:my_secret@my_bucket/data.csv
s3://my_key:my_secret@my_server:my_port@my_bucket/data.csv
gs://my_bucket/data.csv
azure://my_bucket/data.csv
hdfs:///path/data.csv
hdfs://path/data.csv
webhdfs://host:port/path/data.csv
./local/path/data.csv
~/local/path/data.csv
local/path/data.csv
./local/path/data.csv.gz
file:///home/user/file.csv
file:///home/user/file.csv.bz2
[ssh|scp|sftp]://username@host//path/file.csv
[ssh|scp|sftp]://username@host/path/file.csv
[ssh|scp|sftp]://username:password@host/path/file.csv
```

A pipeline can have more than one source and is defined in the [`config.yml`](./config/) within the `pipeline.sources` key. This can either be just a list of one or more `uri`s or of more complex source objects.

#### String source

```yaml
name: gdho

pipeline:
  sources:
    - https://www.humanitarianoutcomes.org/gdho/search/results?format=csv
```

This tells the pipeline to fetch the output from the given url without any more logic.

As seen in the [tutorial](../tutorial/), this source has actually encoding problems and we want to skip the first line. So we need to give investigraph a bit more information on how to extract this source.

#### Object source

For extracting tabular sources, investigraph uses [pandas](https://pandas.pydata.org/) under the hood. This library has a lot of options on how to read in data, and within our `config.yml` we can just pass any arbitrary argument to [`pandas.read_csv`](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.read_csv.html#pandas.read_csv) or [`pandas.read_excel`](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.read_excel.html#pandas-read-excel). (investigraph is picking the right function based on the sources mimetype.)

Just put the required arguments in the config key `pipeline.sources[].extract_kwargs`, in this case (see tutorial) like this:

```yaml
name: gdho

pipeline:
  sources:
    - uri: https://www.humanitarianoutcomes.org/gdho/search/results?format=csv
      extract_kwargs:
        encoding: latin
        skiprows: 1
    - # ... second source
```

Under the hood, this calls
```python
pandas.read_csv(uri, encoding="latin", skiprows=1)
```

#### Named source

You can give a name (or identifier) to the source to be able to identify in your code from which source the generated records are coming from, e.g. to adjust a parsing function based on the source file.

```yaml
name: ec_meetings

pipeline:
  sources:
    - name: ec_juncker
      uri: https://ec.europa.eu/transparencyinitiative/meetings/dataxlsx.do?name=meetingscommissionrepresentatives1419
      extract_kwargs:
        skiprows: 1
    - name: ec_leyen
      uri: https://ec.europa.eu/transparencyinitiative/meetings/dataxlsx.do?name=meetingscommissionrepresentatives1924
      extract_kwargs:
        skiprows: 1
```

This helps us for the [next stage](#transform) (see below) to distinguish between different sources and adjust our parsing code to it.

### Inspecting sources

To iteratively test your configuration, you can use `investigraph inspect` to see what output the extract stage is producing:

    investigraph inspect <path/to/config.yml> --extract

This will output the first few extracted data records in tabular format.

Or, to output the first few records as `json`:

    investigraph inspect <path/to/config.yml> --extract --to-json

## Transform

As outlined, **investigraph** tries to automatize everything *around* this stage. That's because transforming any arbitrary source data into [ftm entities](../concepts/entity/) is very dependant on the actual dataset.

Still, for simple use cases, you don't need to write any `python code` here at all. Just define a *mapping*. For more complex scenarios, write your own `parse` function.

### Mapping

Simply plug in a standardized ftm mapping (as [described here](https://followthemoney.tech/docs/mappings/#mappings)) into your pipeline configuration under the root key `mapping`:

```yaml
name: gdho

mapping:
  queries:
    - entities:
        org:
          schema: Organization
          keys:
            - Id
          properties:
            name:
              column: Name
            # ...
```

As it follows the mapping specification from [Follow The Money](../stack/followthemoney), any existing mapping can be copied over here and a mapping can easily (and independent of investigraph) tested with the ftm command line:

    ftm map-csv ./<dataset>/config.yml -i ./data.csv

Please refer to the [aleph documentation](https://docs.aleph.occrp.org/developers/mappings/) for more details about mappings.

When the config key `mapping` is specified in `config.yml`, investigraph will always use that mapping even if you have a custom `parse.py` as well. Make sure to not have a `mapping` key defined (or comment it out) if you want a custom `parse.py`.

### parse.py

For more complex transforming operations, just write your own code. As described, one of the main values of **investigraph** is that you only have to write this one python file for a dataset, everything else is handled automatically.

By convention (and this is currently hard-coded) the file named `parse.py` has to live in the same folder as `config.yml` and needs to contain at least a function named `parse` with this signature:

```python
def parse(ctx: investigraph.model.Context, data: dict[str, typing.Any]) -> typing.Generator[nomenklatura.entity.CE, None, None]:
    # transform `data` into one or more entities ...
    yield proxy
```

Ok. Let's break this down.

`ctx` contains the actual flow run context with some helpful information like:

- `ctx.dataset` the current dataset name
- `ctx.source` the current source from which the current data record comes from

`data` is the current extracted record.

An actual `parse.py` for the `gdho` dataset could look like this:

```python
from investigraph.util import make_proxy

def parse(ctx, record)
    proxy = make_proxy("Organization")
    proxy.id = record.pop("Id"))
    proxy.add("name", record.pop("Name"))
    # add more property data ...
    yield proxy
```

The util function `make_proxy` creates an [entity](../concepts/entity/), which is implemented in `nomenklatura.entity.CompositeEntity`, with the schema "Organization".

Then following the [ftm python api](https://followthemoney.tech/docs/api/), properties can be added via `proxy.add(<prop>, <value>)`

See [parse](./parse/) for a more complete reference.

### Inspecting transform stage

To iteratively test your configuration, you can use `investigraph inspect` to see what output the transform stage is producing:

    investigraph inspect <path/to/config.yml> --extract

This will output the first few mappend [entities](../concepts/entity/).


## Load

The transformed metadata and [entities](../concepts/entity/) can be written to various local or remote targets, including cloud storage and sql databases.

All outputs can be specified within the prefect ui, the [`config.yml`](./config/) or via command line arguments.

### Metadata index.json

Location for the resulting [dataset metadata](../concepts/dataset/), typically called `index.json`. Again, as investigraph is using [smart_open](https://github.com/RaRe-Technologies/smart_open) (see above), this can basically be anywhere:

**config.yml**

```yaml
# metadata ...
index_uri: s3://my_bucket/<dataset>/index.json
```

**command line**

    investigraph run <dataset> --index-uri sftp://username:password@host/<dataset>/index.json

### Entities

[Entities](../concepts/entity/) can be written to any file uri or directly to a [Follow The Money store](https://github.com/alephdata/followthemoney-store) specified via a sql connection string.

As a convention, entity json files should use the extension `.ftm.json`

**config.yml**

```yaml
# metadata ...
index_uri: s3://my_bucket/<dataset>/entities.ftm.json
```

write to a ftm store:

```yaml
# metadata ...
entities_uri: sqlite:///followthemoney.store
```

Sqlite is only suitable for developing or small local deployments, beter use a proper sql database that allows concurrent writes:

```yaml
# metadata ...
entities_uri: postgresql://user:password@host:port/database
```

**command line**

    investigraph run <dataset> --entities-uri ...

