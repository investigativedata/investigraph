[![Deploy mkdocs site to Pages](https://github.com/investigativedata/investigraph/actions/workflows/build.yml/badge.svg)](https://github.com/investigativedata/investigraph/actions/workflows/build.yml)

# investigraph
etl pipeline, graphical explorer and general toolbox for investigations with follow the money data

## online documentation

https://docs.investigraph.dev

Tutorial: https://docs.investigraph.dev/tutorial/

## build with investigraph

- https://investigraph.eu

## what is this all about?

**Research and implementation of an ETL process for a curated and up-to-date public and open-source data catalog of frequently used datasets in investigative journalism.**

**investigraph** is an [ETL](https://en.wikipedia.org/wiki/Extract,_transform,_load) framework that allows research teams to build their own data catalog themselves as easily and reproducable as possible. The **investigraph** frameworks provides logic for *extracting*, *transforming* and *loading* any data source into [followthemoney entities](https://followthemoney.tech/).

For most common data source formats, this process is possible without programming knowledge, by means of an easy `yaml` specification interface. However, if it turns out that a specific dataset can not be parsed with the built-in logic, a developer can plug in *custom python scripts* at specific places within the pipeline to fulfill even the most edge cases in data processing.

### Value for investigative research teams
- standardized process to convert different data sets into a [uniform and thus comparable format](https://followthemoney.tech)
- control of this process for non-technical people
- Creation of an own (internal) data catalog
- Regular, automatic updates of the data
- A growing community that makes more and more data sets accessible
- Access to a public (open source) data catalog operated by "investigraph"

## components / child repositories
- [investigraph-etl](https://github.com/investigativedata/investigraph-etl) - etl style pipeline framework for followthemoney data based on [prefect.io](https://prefect.io)
- [investigraph-eu](https://github.com/investigativedata/investigraph-eu) - Catalog of european datasets powered by investigraph
- [runpandarun](https://github.com/simonwoerpel/runpandarun) - A simple interface written in python for reproducible i/o workflows around tabular data via [pandas](https://pandas.pydata.org/)
- [ftmq](https://github.com/investigativedata/ftmq) - An attempt towards a [followthemoney](https://github.com/alephdata/followthemoney) query dsl
- [investigraph-site](https://github.com/investigativedata/investigraph-site) - Landing page for investigraph (next.js app)
- [investigraph-api](https://github.com/investigativedata/investigraph-api) - public API instance to use as a test playground
- [runpandarun](https://github.com/simonwoerpel/runpandarun) - A simple interface written in python for reproducible i/o workflows around tabular data via [pandas](https://pandas.pydata.org/)
- [ftm-joy-ui](https://github.com/investigativedata/ftm-joy-ui/) - React components based on [Joy UI](https://mui.com/joy-ui/getting-started/overview/) for rendering [follow the money](https://followthemoney.tech) stuff
- [ftmstore-fastapi](https://github.com/investigativedata/ftmstore-fastapi) - Lightweight API that exposes a ftm store to a public endpoint. Will be improved during this project.

## 3rd party contributions
This project builds on top of great technology. Contributions to 3rd party libraries are listet below.

### nomenklatura
- [Add optional dataset category and frequency metadata](https://github.com/opensanctions/nomenklatura/commit/ca6eab89c0a468f4dcb8b79045a7ccb9625787bd)

## Rendering / static page

This documentation can be rendered via [mkdocs](https://www.mkdocs.org/) using the [mkdocs-material](https://squidfunk.github.io/mkdocs-material/) theme.

Local developement:

    pip install -r requirements.txt

    mkdocs serve

Follow the documentation at [mkdocs-material](https://squidfunk.github.io/mkdocs-material/getting-started/)

### build

    mkdocs build

## supported by
[Media Tech Lab Bayern batch #3](https://github.com/media-tech-lab)

<a href="https://www.media-lab.de/en/programs/media-tech-lab">
    <img src="https://raw.githubusercontent.com/media-tech-lab/.github/main/assets/mtl-powered-by.png" width="240" title="Media Tech Lab powered by logo">
</a>
