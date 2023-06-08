# investigraph

**Research and implementation of an ETL process for a curated and up-to-date public and open-source data catalog of frequently used datasets in investigative journalism.**

[Head over to the tutorial](./tutorial/)

## abstract

The result is an ETL framework that allows research teams to build their own data catalog themselves as easily as possible and without much coding, and to incrementally update the individual datasets (e.g., through automated web scraping). This process (data import & update) should be possible without programming knowledge, by means of a frontend. However, it cannot be ruled out that for the 1st step (extraction) of an ETL pipeline for a given dataset, some coding is still needed, as each source is individual and may require special parsing. This will be partially addressed by a util library that provides adapters for common data inputs (json, csv, web-api).

### Value for investigative research teams
- standardized process to convert different data sets into a [uniform and thus comparable format](https://followthemoney.tech)
- control of this process for non-technical people
- Creation of an own (internal) data catalog
- Regular, automatic updates of the data
- A growing community that makes more and more data sets accessible
- Access to a public (open source) data catalog operated by [investigativedata.io](https://investigativedata.io)

## github repositories
- [investigraph](https://github.com/investigativedata/investigraph) - The meta repo from which this page is rendered
- [investigraph-etl](https://github.com/investigativedata/investigraph-etl) - The main codebase for the etl pipeline framework based on prefect.io
- [investigraph-datasets](https://github.com/investigativedata/investigraph-datasets) - Example datasets configuration
- [investigraph-site](https://github.com/investigativedata/investigraph-site) - Landing page for investigraph (next.js app)
- [investigraph-api](https://github.com/investigativedata/investigraph-api) - public API instance to use as a test playground
- [ftmq](https://github.com/investigativedata/ftmq) - An attempt towards a [followthemoney](https://github.com/alephdata/followthemoney) query dsl
- [ftmstore-fastapi](https://github.com/investigativedata/ftmstore-fastapi) - Lightweight API that exposes a ftm store to a public endpoint.

## supported by
[Media Tech Lab Bayern batch #3](https://github.com/media-tech-lab)

<a href="https://www.media-lab.de/en/programs/media-tech-lab">
    <img src="https://raw.githubusercontent.com/media-tech-lab/.github/main/assets/mtl-powered-by.png" width="240" title="Media Tech Lab powered by logo">
</a>
