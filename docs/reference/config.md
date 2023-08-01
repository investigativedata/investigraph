# config.yml

The main entry point for a specific [dataset](../concepts/dataset.md) configuration. This file should be placed within a [block](https://docs.prefect.io/latest/concepts/blocks/) under a subfolder named by the dataset, e.g.: `./path-to-datasets/<dataset>/config.yml`

When not using blocks (as for local developement), any arbitrary config files can be referenced to use via [command line](./cli.md):

    investigraph run -c ./path/to/config/file.yml

## Reference

### Dataset metadata

#### `name`

**required**

Dataset identifier, as a slug

Example: `ec_meetings`

#### `title`

Human-readable title of the dataset

Example: `European Commission - Meetings with interest representatives`

Default: capitalized `name` from above.

#### `prefix`

slug prefix for [entity](../concepts/entity.md) IDs.

Example: `ec`

Default: `None`

#### `country`

2-letter iso code of the main country this dataset is related to. Also accepts `eu`.

Example: `eu`

Default: `None`

#### `summary`

A description about the dataset, can be multi-lined.

Example:

```yaml
description: |
    The Commission applies strict rules on transparency concerning its contacts
    and relations with interest representatives. # ...
```

Default: `None`

#### `resources`

A list of recources that hold [entities](../concepts/entity.md) from this dataset.

Example:

```yaml
resources:
  - name: entities.ftm.json
    url: https://data.ftm.store/investigraph/ec_meetings/entities.ftm.json
    mime_type: application/json+ftm
  - # ...
```

Default: `None`

#### `publisher`

Publisher of the dataset as an object. Required key: `name`

Example:

```yaml
publisher:
  name: European Commission Secretariat-General
  description: |
    The Secretariat-General is responsible for the overall coherence of the
    Commission’s work – both in shaping new policies, and in steering them
    through the other EU institutions. It supports the whole Commission.
  url: https://commission.europa.eu/about-european-commission/departments-and-executive-agencies/secretariat-general_en
```

Default: `None`

### Extract stage

Configuration for the extraction stage, for fetching sources and extracting records to transform in the next stage.

```yaml
extract:
  # ...
```

#### `extract.sources`

[See sources](../#source)

#### `extract.handler`

Reference to the python function that handles this stage.

Default: `investigraph.logic.extract:handle`

When using your own extractor, you can disable source fetching by investigraph, instead fetch (and extract) your sources within your own code:

```yaml
extract:
  handler: ./extract.py:handle
  fetch: false
```

Or, a python module (must be in `PYTHONPATH`)

```yaml
extract:
  handler: my_module.extractors:json
```

#### `extract.pandas`

Pandas operations to apply to the data (see [runpandarun](https://github.com/simonwoerpel/runpandarun)), including [datapatch](https://github.com/pudo/datapatch)

```yaml
extract:
  pandas:
    read:
      options:
        skiprows: 2
    operations:
      - handler: DataFrame.fillna
        options:
          value: ""
    patch:
      countries:
        - match: "Greet Britain"
          value: "Great Britain"
```

Can also be applied per source:

```yaml
extract:
  sources:
    - uri: test.csv
      options:
        pandas:
          # ...
```

### Transform

Configuration for the transformation stage, for defining a [FollowTheMoney mapping](../stack/followthemoney.md) or referencing custom transformation code. When a custom handler is defined, the query mapping is ignored.

```yaml
transform:
  handler: ./transform.py:handle
  queries:
    - entities:
    # ...
```

### Load

The final stage that loads the transformed [Entities](../concepts/entity.md) into defined targets.

```yaml
load:
  # ...
```

#### `load.index_uri`

Uri to output dataset metadata. Can be anything that `fsspec` understands.

**Example**: `s3://<bucket-name>/<dataset-name>/index.json`

**Default**: `./data/<dataset-name>/index.json`

#### `load.entities_uri`

Uri to output transformed entities. Can be anything that `fsspec` understands, plus a `SQL` endpoint (for use with [followthemoney-store](https://github.com/alephdata/followthemoney-store))

**Example**:

- `s3://<bucket-name>/<dataset-name>/entities.ftm.json`
- `postgresql://user:password@host:port/database`

**Default**: `./data/<dataset-name>/entities.ftm.json`

#### `load.fragments_uri`

Uri to output intermediate entity fragments. Can be anything that `fsspec` understands.

**Example**: `s3://<bucket-name>/<dataset-name>/fragments.json`

**Default**: `./data/<dataset-name>/fragments.json`

### Aggregate

Specify if entities should be aggregated and how. Per default, aggregation happens in memory.

Turn off aggregation completly:

```yaml
aggregate: false
```

#### `aggregate.handler`

If datasets are too large to fit into memory, aggregation can happen within a database (specified via the `FTM_DATABASE_URI` env var):

```yaml
aggregate:
  handler: db
```

This can be a custom handler as well (as in the other stages), e.g.:

```yaml
aggregate:
  handler: ./aggregate.py:handle
```

[See aggregate.py for details](./aggregate.md)

#### `aggregate.db_uri`

Specify the database connection when the `db` handler is used.

```yaml
aggregate:
  handler: db
  db_uri: postgresql:///my_database
```


## A complete example

Taken from the [tutorial](../tutorial.md)

```yaml
name: gdho
title: Global Database of Humanitarian Organisations
prefix: gdho
summary: |
  GDHO is a global compendium of organisations that provide aid in humanitarian
  crises. The database includes basic organisational and operational
  information on these humanitarian providers, which include international
  non-governmental organisations (grouped by federation), national NGOs that
  deliver aid within their own borders, UN humanitarian agencies, and the
  International Red Cross and Red Crescent Movement.
resources:
  - name: entities.ftm.json
    url: https://data.ftm.store/investigraph/gdho/entities.ftm.json
    mime_type: application/json+ftm
publisher:
  name: Humanitarian Outcomes
  description: |
    Humanitarian Outcomes is a team of specialist consultants providing
    research and policy advice for humanitarian aid agencies and donor
    governments.
  url: https://www.humanitarianoutcomes.org


extract:
  sources:
    - uri: https://www.humanitarianoutcomes.org/gdho/search/results?format=csv
      pandas:
        read:
          options:
            encoding: latin
            skiprows: 1

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
            weakAlias:
              column: Abbreviated name
            legalForm:
              column: Type
            website:
              column: Website
            country:
              column: HQ location
            incorporationDate:
              column: Year founded
            dissolutionDate:
              column: Year closed
            sector:
              columns:
                - Sector
                - Religious or secular
                - Religion

load:
  index_uri: s3://s3.investigativedata.org@data.ftm.store/investigraph/gdho/index.json
  entities_uri: s3://s3.investigativedata.org@data.ftm.store/investigraph/gdho/entities.ftm.json

aggregate:
  handler: db
```
