# config.yml

The main entry point for a specific [dataset](../../concepts/dataset/) configuration. This file should be placed within a [block](https://docs.prefect.io/2.10.11/concepts/blocks/) under a subfolder named by the dataset, e.g.: `./path-to-datasets/<dataset>/config.yml`

When not using blocks (as for local developement), any arbitrary config files can be referenced to use via [command line](../cli/):

    investigraph run <dataset> -c ./path/to/config/file.yml

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

slug prefix for [entity](../../concepts/entity/) IDs.

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

A list of recources that hold [entities](../../concepts/entity/) from this dataset.

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

### Pipeline

### Mapping

## A complete example

Taken from the [tutorial](../../tutorial/)

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


index_uri: s3://s3.investigativedata.org@data.ftm.store/investigraph/gdho/index.json
entities_uri: s3://s3.investigativedata.org@data.ftm.store/investigraph/gdho/entities.ftm.json

pipeline:
  sources:
    - uri: https://www.humanitarianoutcomes.org/gdho/search/results?format=csv
      extract_kwargs:
        encoding: latin
        skiprows: 1

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
```
