# Overview

**investigraph** is a framework to orchestrate data processing workflows that transform source data into [entities](../concepts/entity.md).

This framework tries to automatize as many functionality (scheduling and executing workflows, monitoring, extracting and storing to various local or remote sources, configuration, ...) as possible with the help of [prefect.io](../stack/prefect.md).

As **investigraph** can be considered as an [ETL-process](https://en.wikipedia.org/wiki/Extract,_transform,_load) for [Follow The Money data](../stack/followthemoney.md), the structure (of the codebase and this overview documentation) roughly follows the three steps of such a pipeline: *extract, transform, load*.

The following documentation assumes you already checked out [the tutorial](../tutorial.md). The documentation on this page covers the whole pipeline process more in depth. For a complete (technical) reference, check out the references for the core building blocks of **investigraph**:

- [config.yml](config.md)
- [extract.py](extract.md)
- [transform.py](transform.md)
- [load.py](load.md)

Most of the running behaviour of a specific pipeline is configured on a per-[dataset](../concepts/dataset.md) basis and/or via arguments given to a specific run of the pipeline, either via the prefect ui or via command line.

## Extract

In the first step of a pipeline, we focus on getting one or more data sources and extracting data records from them that will eventually be passed to the [next stage](#transform).

This stage is configured via the `extract` key within the `config.yml`

### Source

A data source is defined by a `uri`. As investigraph is using [fsspec](https://github.com/fsspec/filesystem_spec) under the hood, this `uri` can be anything from a local file path to a remote s3 resource.

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

And, of course, just `http[s]://...`

A pipeline can have more than one source and is defined in the [`config.yml`](./config.md) within the `extract.sources` key. This can either be just a list of one or more `uri`s or of more complex source objects.

#### Simple source

```yaml
extract:
  sources:
    - uri: https://www.humanitarianoutcomes.org/gdho/search/results?format=csv
```

This tells the pipeline to fetch the output from the given url without any more logic.

As seen in the [tutorial](../tutorial.md), this source has actually encoding problems and we want to skip the first line. So we need to give investigraph a bit more information on how to extract this source.

#### Named source

You can give a name (or identifier) to the source to be able to identify in your code from which source the generated records are coming from, e.g. to adjust a parsing function based on the source file.

```yaml
extract:
  sources:
    - name: ec_juncker
      uri: https://ec.europa.eu/transparencyinitiative/meetings/dataxlsx.do?name=meetingscommissionrepresentatives1419
    - name: ec_leyen
      uri: https://ec.europa.eu/transparencyinitiative/meetings/dataxlsx.do?name=meetingscommissionrepresentatives1924
```

This helps us for the [next stage](#transform) (see below) to distinguish between different sources and adjust our parsing code to it.

#### More configurable source

For extracting most kinds of sources, investigrap uses [runpandarun](../stack/runpandarun.md) under the hood. This is a wrapper around [pandas](https://pandas.pydata.org) that allows specifying a pandas workflow as a yaml playbook. Pandas has a lot of options on how to read in data, and within our `config.yml` we can just pass any arbitrary argument to [`pandas.read_csv`](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.read_csv.html#pandas.read_csv) or [`pandas.read_excel`](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.read_excel.html#pandas-read-excel). (`runpandarun` is picking the right function based on the sources mimetype.)

Just put the required arguments in the config key `extract.sources[].pandas`, in this case (see tutorial) like this:

```yaml
extract:
  sources:
    - uri: https://www.humanitarianoutcomes.org/gdho/search/results?format=csv
      pandas:
        read:
          options:
            encoding: latin
            skiprows: 1

```

Under the hood, this calls
```python
pandas.read_csv(uri, encoding="latin", skiprows=1)
```

If `runpandarun` is not able to detect the handler to read in the source, as happening in misconfigured web headers or wrong file extensions, you can manually specify the `read.handler`:

```yaml
extract:
  sources:
    - uri: https://www.humanitarianoutcomes.org/gdho/search/results?format=csv
      pandas:
        read:
          handler: read_csv
          options:
            encoding: latin
            skiprows: 1
```

#### Prepare your data with pandas

In case you want to use the built-in support for [followthemoney mappings](https://followthemoney.tech/docs/mappings/#mappings), you might need to adjust the incoming data a bit more, as per design, `followthemoney` expects an already quite cleaned tabular source.

With the help of [runpandarun](../stack/runpandarun.md) we can basically do anything we need with the source data:

```yaml
extract:
  sources:
    - uri: ./data.csv
      pandas:
        read:
          options:
            skiprows: 3
        operations:
          - handler: DataFrame.rename
            options:
              columns:
                value: amount
                "First name": first_name
          - operations: DataFrame.fillna
            options:
              value: ""
          - handler: Series.map
            column: slug
            options:
              func: "lambda x: normality.slugify(x) if isinstance(x) else 'NO DATA'"
```

This "pandas playbook" translates into these python calls that **investigraph** will run:

```python
import pandas as pd
import normality

df = pd.read_csv("./data.csv", skiprows=3)
df = df.rename(columns={"value": "amount", "First name": "first_name"})
df = df.fillna("")
df["slug"] = df["slug"].map(lambda x: normality.slugify(x) if isinstance(x) else 'NO DATA')
```

Refer to the [runpandarun documentation](https://github.com/simonwoerpel/runpandarun) for more.


#### Named source

You can give a name (or identifier) to the source to be able to identify in your code from which source the generated records are coming from, e.g. to adjust a parsing function based on the source file.

```yaml
extract:
  sources:
    - name: ec_juncker
      uri: https://ec.europa.eu/transparencyinitiative/meetings/dataxlsx.do?name=meetingscommissionrepresentatives1419
    - name: ec_leyen
      uri: https://ec.europa.eu/transparencyinitiative/meetings/dataxlsx.do?name=meetingscommissionrepresentatives1924
```

This helps us for the [next stage](#transform) (see below) to distinguish between different sources and adjust our parsing code to it.

### Bring your own code

When using a custom handler that handles the fetch & extraction logic, disable the fetch logic from **investigraph** and specify the custom script (or module):

```yaml
extract:
  fetch: false
  handler: ./myscript.py:extract
```

This function has to yield a `dict[str, Any]` for each record that should be passed to the next stage:

```python
import csv
import requests
from io import StringIO
from typing import Any, Generator
from investigraph.model import Context

def extract(ctx: Context) -> Generator[dict[str, Any], None, None]:
    res = requests.get(ctx.source.uri)
    yield from csv.DictReader(StringIO(res.text))
```

For more information about how to include custom code, see the relevant section in the [transform](#transform) stage.

### Inspecting sources

To iteratively test your configuration, you can use `investigraph inspect` to see what output the extract stage is producing:

    investigraph inspect <path/to/config.yml> --extract

This will output the first few extracted data records in tabular format.

Or, to output the first few records as `json`:

    investigraph inspect <path/to/config.yml> --extract --to-json

## Transform

As outlined, **investigraph** tries to automatize everything *around* this stage. That's because transforming any arbitrary source data into [ftm entities](../concepts/entity.md) is very dependant on the actual dataset.

Still, for simple use cases, you don't need to write any `python code` here at all. Just define a *mapping*. For more complex scenarios, write your own `transform` function.

### Mapping

Simply plug in a standardized ftm mapping (as [described here](https://followthemoney.tech/docs/mappings/#mappings)) into your pipeline configuration under the root key `transform.queries`:

```yaml
transform:
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

As it follows the mapping specification from [Follow The Money](../stack/followthemoney.md), any existing mapping can be copied over here and a mapping can easily (and independent of investigraph) tested with the ftm command line:

    ftm map-csv ./<dataset>/config.yml -i ./data.csv

Please refer to the [aleph documentation](https://docs.aleph.occrp.org/developers/mappings/) for more details about mappings.

### Bring your own code

For more complex transforming operations, just write your own code. As described, one of the main values of **investigraph** is that you only have to write this one python file for a dataset, everything else is handled automatically.

In the `<stage>.handler` key, you can either refer to a python function via it's module path, or to a file path to a python script containing the function. In that case, by convention the python files should be named after their stages (`extract.py`, `transform.py`, `load.py`) and live in the same directory as the `config.yml`.

#### Refer a function from a module

The module must be within the current `PYTHONPATH` at runtime.

```yaml
transform:
    handler: my_library.transformers:wrangle
```

#### Refer a function from a local python script file

This file must be locally accessible on the running host. This can be achieved via prefect blocks.

```yaml
transform:
    handler: ./transform.py:handle
```

The entrypoint function for the **transform stage** has the following signature:

```python
def handle(ctx: investigraph.model.Context, data: dict[str, typing.Any], ix: int) -> typing.Generator[nomenklatura.entity.CE, None, None]:
    # transform `data` into one or more entities ...
    yield proxy
```

Ok. Let's break this down.

`ctx` contains the actual flow run context with some helpful information like:

- `ctx.dataset` the current dataset name
- `ctx.source` the current source from which the current data record comes from

`data` is the current extracted record.

`ix` is an integer of the index of the current record.

An actual `transform.py` for the `gdho` dataset could look like this:

```python
def parse(ctx, record, ix):
    proxy = ctx.make_proxy("Organization")
    proxy.id = record.pop("Id"))
    proxy.add("name", record.pop("Name"))
    # add more property data ...
    yield proxy
```

The util function `make_proxy` creates an [entity](../concepts/entity.md), which is implemented in `nomenklatura.entity.CompositeEntity`, with the schema "Organization".

Then following the [ftm python api](https://followthemoney.tech/docs/api/), properties can be added via `proxy.add(<prop>, <value>)`

### Inspecting transform stage

To iteratively test your configuration, you can use `investigraph inspect` to see what output the transform stage is producing:

    investigraph inspect <path/to/config.yml> --extract

This will output the first few mappend [entities](../concepts/entity.md).

## Load

The transformed metadata and [entities](../concepts/entity.md) can be written to various local or remote targets, including cloud storage and sql databases.

All outputs can be specified within the prefect ui, the [`config.yml`](./config.md) or via command line arguments.

### Metadata

Location for the resulting [dataset metadata](../concepts/dataset.md), typically called `index.json`. Again, as investigraph is using [fsspec](https://github.com/fsspec/filesystem_spec) (see above), this can basically be anywhere:

**config.yml**

```yaml
load:
  index_uri: s3://my_bucket/<dataset>/index.json
```

**command line**

    investigraph run ... --index-uri sftp://username:password@host/<dataset>/index.json

### Fragments

investigraph has to store the intermediate entity fragments somewhere before merging them into entities in the last step. Per default, fragments are written to local files, but if you are using a decentralized setup where several agents are emitting fragments, you should specify a remote uri for it:

    investigraph run ... --fragments-uri s3://my_bucket/<dataset>/fragments.json

This can as well be defined in the datasets [`config.yml`](./config.md):

```yaml
load:
  fragments_uri: sftp://username:password@host/<dataset>/index.json
```


### Entities

[Entities](../concepts/entity.md) can be written to any file uri or directly to a [Follow The Money store](https://github.com/alephdata/followthemoney-store) specified via a sql connection string.

As a convention, entity json files should use the extension `.ftm.json`

**config.yml**

```yaml
load:
  entities_uri: s3://my_bucket/<dataset>/entities.ftm.json
```

write to a ftm store:

```yaml
load:
  entities_uri: sqlite:///followthemoney.store
```

Sqlite is only suitable for developing or small local deployments, beter use a proper sql database that allows concurrent writes:

```yaml
load:
  entities_uri: postgresql://user:password@host:port/database
```

**command line**

    investigraph run ... --entities-uri ...

## Aggregate

One essential feature from the underlying [followthemoney toolkit](../stack/followthemoney.md) is the so called "entity fragmentation". This means, pipelines can output *partial* data for a given entity and later merge them together. For example, if one data source has information about a `Person`s birth date, and another has information about the nationality of this person, the two different pipelines would produce two different fragments of the same [entity](../concepts/entity/) that are aggregated at a later stage. [Read more about the technical details here.](https://followthemoney.tech/docs/fragments/)

Aggregation can happen in memory (per default) or via iterating through a sql database (if the complete data doesn't fit into the machines memory).

To disable aggregation, set the flag in the prefect ui when starting a flow, or specify via command-line:

    investigraph run ... --no-aggregate

Or in the yaml config:

```yaml
aggregate: False
```

