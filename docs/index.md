[![investigraph on pypi](https://img.shields.io/pypi/v/investigraph)](https://pypi.org/project/investigraph/)
[![Python test and package](https://github.com/investigativedata/investigraph-etl/actions/workflows/python.yml/badge.svg)](https://github.com/investigativedata/investigraph-etl/actions/workflows/python.yml)
[![Build docker container](https://github.com/investigativedata/investigraph-etl/actions/workflows/build-docker.yml/badge.svg)](https://github.com/investigativedata/investigraph-etl/actions/workflows/build-docker.yml)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![Coverage Status](https://coveralls.io/repos/github/investigativedata/investigraph-etl/badge.svg?branch=main)](https://coveralls.io/github/investigativedata/investigraph-etl?branch=main)
[![MIT License](https://img.shields.io/pypi/l/investigraph)](https://github.com/investigativedata/investigraph-etl/blob/main/LICENSE)

# Investigraph

**Research and implementation of an ETL process for a curated and up-to-date public and open-source data catalog of frequently used datasets in investigative journalism.**

[Head over to the tutorial](./tutorial.md)

## About

**investigraph** is an [ETL](https://en.wikipedia.org/wiki/Extract,_transform,_load) framework that allows research teams to build their own data catalog themselves as easily and reproducable as possible. The **investigraph** framework provides logic for *extracting*, *transforming* and *loading* any data source into [followthemoney entities](https://followthemoney.tech/).

For most common data source formats, this process is possible without programming knowledge, by means of an easy `yaml` specification interface. However, if it turns out that a specific dataset can not be parsed with the built-in logic, a developer can plug in *custom python scripts* at specific places within the pipeline to fulfill even the most edge cases in data processing.

### Features
- Cached data fetching based on `HEAD` requests and their response headers
- Data extraction based on `pandas` ([runpandarun](https://github.com/simonwoerpel/runpandarun))
- Data patching via [datapatch](https://github.com/pudo/datapatch)
- Transforming data records into [followthemoney](https://followthemoney.tech) entities via mappings
- Loading result data into a various range of targets, including cloud storage (via [fsspec](https://filesystem-spec.readthedocs.io/en/latest/index.html)) or sql databases (via [followthemoney-store](https://github.com/alephdata/followthemoney-store))
- "Bring your own code" and plug it in into the right stage if the built-in logic doesn't fit your use case

### Value for investigative research teams
- standardized process to convert different data sets into a [uniform and thus comparable format](https://followthemoney.tech)
- control of this process for non-technical people
- Creation of an own (internal) data catalog
- Regular, automatic updates of the data
- A growing community that makes more and more data sets accessible
- Access to a public (open source) data catalog operated by [investigativedata.io](https://investigativedata.io)

## Github repositories
- [investigraph-etl](https://github.com/investigativedata/investigraph-etl) - etl style pipeline framework for followthemoney data based on [prefect.io](https://prefect.io)
- [investigraph-eu](https://github.com/investigativedata/investigraph-eu) - Catalog of european datasets powered by investigraph
- [runpandarun](https://github.com/simonwoerpel/runpandarun) - A simple interface written in python for reproducible i/o workflows around tabular data via [pandas](https://pandas.pydata.org/)
- [ftmq](https://github.com/investigativedata/ftmq) - An attempt towards a [followthemoney](https://github.com/alephdata/followthemoney) query dsl
- [investigraph-datasets](https://github.com/investigativedata/investigraph-datasets) - Example datasets configuration
- [investigraph-site](https://github.com/investigativedata/investigraph-site) - Landing page for investigraph (next.js app)
- [investigraph-api](https://github.com/investigativedata/investigraph-api) - public API instance to use as a test playground
- [ftmstore-fastapi](https://github.com/investigativedata/ftmstore-fastapi) - Lightweight API that exposes a ftm store to a public endpoint.

## Supported by
[Media Tech Lab Bayern batch #3](https://github.com/media-tech-lab)

<a href="https://www.media-lab.de/en/programs/media-tech-lab">
    <img src="https://raw.githubusercontent.com/media-tech-lab/.github/main/assets/mtl-powered-by.png" width="240" title="Media Tech Lab powered by logo">
</a>
