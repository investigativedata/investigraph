# investigraph
etl pipeline, graphical explorer and general toolbox for investigations with follow the money data

## what is this all about?

**Research and implementation of an ETL process for a curated and up-to-date public and open-source data catalog of frequently used datasets in investigative journalism.**

The result is an ETL framework that allows research teams to build their own data catalog themselves as easily as possible and without much coding, and to incrementally update the individual datasets (e.g., through automated web scraping). This process (data import & update) should be possible without programming knowledge, by means of a frontend. However, it cannot be ruled out that for the 1st step (extraction) of an ETL pipeline for a given dataset, some coding is still needed, as each source is individual and may require special parsing. This will be partially addressed by a util library that provides adapters for common data inputs (json, csv, web-api).

### Value for investigative research teams
- standardized process to convert different data sets into a [uniform and thus comparable format](https://followthemoney.tech)
- control of this process for non-technical people
- Creation of an own (internal) data catalog 
- Regular, automatic updates of the data
- A growing community that makes more and more data sets accessible
- Access to a public (open source) data catalog operated by "investigraph"

## components / child repositories
- [investigraph-prefect](https://github.com/investigativedata/investigraph-prefect) - Trying out prefect.io for ftm pipeline processing 
- [investigraph-site](https://github.com/investigativedata/investigraph-site) - Landing page for investigraph (next.js app)
- [investigraph-api](https://github.com/investigativedata/investigraph-api) - public API instance to use as a test playground
- [ftmq](https://github.com/investigativedata/ftmq) - An attempt towards a [followthemoney](https://github.com/alephdata/followthemoney) query dsl

## 3rd party contributions
This project builds on top of great technology. Contributions to 3rd party libraries are listet below.

## supported by
[Media Tech Lab Bayern batch #3](https://github.com/media-tech-lab)

<a href="https://www.media-lab.de/en/programs/media-tech-lab">
    <img src="https://raw.githubusercontent.com/media-tech-lab/.github/main/assets/mtl-powered-by.png" width="240" title="Media Tech Lab powered by logo">
</a>
