# Data Catalog

A **data catalog** is a collection of one or more [datasets](../dataset/) that has a specific topical manner, like "COVID datasets" or "Company registries". Datasets itself can be in multiple catalogs.

A catalog is found remotely as a `JSON` file that holds the [metadata](#metadata) and references resource files for the included datasets.

## Examples

Common catalogs:

- Investigraph catalog: [https://data.ftm.store/catalog.json](https://data.ftm.store/catalog.json)
- OpenSanctions catalog: [https://data.opensanctions.org/datasets/latest/index.json](https://data.opensanctions.org/datasets/latest/index.json)

## Metadata

The catalog model for **investigraph** is adapted from the [nomenklatura](../../stack/nomenklatura) library.

It requires one property, `datasets`, which is a list of [datasets](../dataset/)

```json
{
    "datasets": [ ... ],
    "updated_at": ""  # optional
}
```

There are more properties found in different catalogs (e.g. OpenSanctions) that are useful for rendering the catalog metadata and ingesting it's datasets.

