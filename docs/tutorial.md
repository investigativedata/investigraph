# Tutorial

**investigraph** tries to automatize as many functionality (scheduling and executing workflows, monitoring, configuration, ...) as possible with the help of [prefect.io](../stack/prefect/).

The only thing you have to manage by yourself is the **dataset configuration**, which, in the easiest scenario, is just a `YAML` file that contains a bit of metadata and pipeline instructions.

The following tutorial is a simple setup on your local machine and only requires recent python >= 3.10.

## 1. Installation

It is highly recommended to use a [python virtual environment](https://learnpython.com/blog/how-to-use-virtualenv-python/) for installation.

    pip install git+https://github.com/investigativedata/investigraph-etl.git

After completion, verify that **investigraph** is installed:

    investigraph --help


## 2. Create a dataset definition

Let's start with a simple, public available dataset: [The Global Databse of Humanitarian Organisations](https://www.humanitarianoutcomes.org/gdho/search). It's just a list of, yes, humanitarian organisations.

### Metadata

Every dataset needs a unique identifier as a sub-folder in our block, let's use `gdho`. We will reference this dataset always with this identifier.

Create a subfolder:

    mkdir -p datasets/gdho

Create the configuration file with the editor of your choice. The path to the file (by hardcoded convention) will now be:

    datasets/gdho/config.yml

Enter the identifier and a bit of metadata into the file:

```yaml
name: gdho
title: Global Database of Humanitarian Organisations
publisher:
  name: Humanitarian Outcomes
  url: https://www.humanitarianoutcomes.org
```

That's enough metadata for now, there is a lot more metadata possible which will be covered in the documentation.

### Sources

The most interesting part of course is the pipeline definition! We have at least to provide a source:

```yaml
# metadata ...
pipeline:
  sources:
    - uri: <url>
```

We need to find out the remote url we want to fetch. So, open the [landing page](https://www.humanitarianoutcomes.org/gdho/search) from the GDHO dataset.

When clicking on "VIEW ALL DATA", it will open [this page](https://www.humanitarianoutcomes.org/gdho/search). And, great! There is a direct link to "DOWNLOAD CSV" which actually returns data in csv format: [https://www.humanitarianoutcomes.org/gdho/search/results?format=csv](https://www.humanitarianoutcomes.org/gdho/search/results?format=csv)

We can just add this url to our source configuration:

```yaml
# metadata ...
pipeline:
  sources:
    - uri: https://www.humanitarianoutcomes.org/gdho/search/results?format=csv
```

**investigraph** allows to interactively inspect your building blocks for datasets, so let's try:

    investigraph inspect ./datasets/gdho/config.yml

This will show an error about no parsing function defined, but we will fix that later.

We can inspect the outcome from our remote source as well:

    investigraph inspect ./datasets/gdho/config.yml --extract

Ooops! This shows us a python exception saying something about `utf-8` error. Yeah, we still have that in 2023.

When downloading this csv file manually and opening in a spreadsheet application, you will actually notice that it is in `latin` encoding and has 1 empty row at the top. 🤦 (welcome to real world data)

Under the hood, **investigraph** is using [pandas.read_csv](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.read_csv.html#pandas.read_csv) and there is an option `extract_kwargs` to pass arguments to pandas on how to read this csv. In this case, it would look like this (refer to the `pandas` documentation for all options):


```yaml
# metadata ...
pipeline:
  sources:
    - uri: https://www.humanitarianoutcomes.org/gdho/search/results?format=csv
      extract_kwargs:
        encoding: latin
        skiprows: 1
```

Now **investigraph** is able to fetch and parse the csv source:

    investigraph inspect ./datasets/gdho/config.yml --extract

### Transform data

This is the core functionality of this whole thing: Transform extracted source data into the [followthemoney](https://followthemoney.tech) model.

The easiest way is to define a mapping of csv columns to ftm properties, [as described here](https://docs.aleph.occrp.org/developers/mappings/).

The format in **investigraph**s `config.yml` aligns with the ftm mapping spec, so you could use any existing mapping here as well.

For the `gdho` dataset, we want to create [Organization](https://followthemoney.tech/explorer/schemata/Organization/) entities and map the name column to the name property.

Add this mapping spec to the `config.yml` (the csv column with the name is called `Name`, so this is a no-brainer):

```yaml
# metadata ...
# pipeline ...
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
```

You can inspect the transformation like this:

    investigraph inspect datasets/gdho/config.yml --transform

Yay – it is returning some [ftm entities](../concepts/entity)

In the source data is a lot more metadata about the organizations. Refer to the [ftm mapping documentation](https://docs.aleph.occrp.org/developers/mappings/) on how to map data. Let's add the organizations website to the `properties` key:

```yaml
# metadata ...
# pipeline ...
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
            website:
              column: Website
```

Inspect again, and the entities now have the `website` property.

### The complete config.yml

Adding in a bit more metadata and property mappings:

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
publisher:
  name: Humanitarian Outcomes
  description: |
    Humanitarian Outcomes is a team of specialist consultants providing
    research and policy advice for humanitarian aid agencies and donor
    governments.
  url: https://www.humanitarianoutcomes.org

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
          key_literal: gdho
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

## 3. Run the pipeline

To actually run the pipeline within the **investigraph framework** (which is based on prefect.io), execute a flow run:

    investigraph run gdho -c datasets/gdho/config.yml

Voilà, you just transformed the whole gdho database into ftm entities! You may notice, that this execution created a new subfolder in the current working directory named `data/gdho` where you find the data output of this process.

## The prefect ui

Start the local prefect server:

    prefect server start

In another terminal window, start an agent:

    prefect agent start -q default

View the dashboard at [http://127.0.0.1:4200](http://127.0.0.1:4200)

There you will already see our recent flow run for the `gdho` dataset.

To be able to run flows from within the ui, we first need to create (and apply) a [deployment](https://docs.prefect.io/2.10.11/concepts/deployments/):

    prefect deployment build investigraph.pipeline:run -n investigraph-local -a

Now, you can see the local deployment in the Deployments tab in the flow view.

You can click on the deployment, and then click on "Run >" at the upper right corner of the deployment view.

In the options, insert `gdho` as the dataset and `./datasets/gdho/config.yml` as the value for the config. Then click "Run" and watch the magic happen.

## Optional: dataset configuration discovery

We use [prefect blocks](https://docs.prefect.io/2.10.11/concepts/blocks/) to store datasets configuration. Using blocks allows **investigraph** to discover dataset configuration (and even parsing code) *everywhere* on the cloud, but let's start locally for now.

Register your local datasets folder as a `LocalFileSystem`-Block in prefect:

    investigraph add-block -b local-file-system/datasets -u ./datasets

From now on, you can reference this block storage with its name `local-file-system/datasets`, e.g. when running the pipeline:

    investigraph run gdho -b local-file-system/datasets

Or reference this block when triggering a flow run via the prefect ui (no need to put in a config path then anymore.)

Of course, these blocks can be created via the prefect ui as well: [http://127.0.0.1:4200/blocks](http://127.0.0.1:4200/blocks)

### Github block

**investigraph** maintains an example [github repository](https://github.com/investigativedata/investigraph-datasets) to use as a block to fetch the dataset configs remotely. Create a github block via the prefect ui or via command line:

    investigraph add-block -b github/investigraph-datasets -u https://github.com/investigativedata/investigraph-datasets.git

Now, you can use this block when running flows (via the ui) or command line:

    investigraph run gdho -b github/investigraph-datasets

## Optional: use python code to transform data

Instead of writting the ftm mapping in the `config.yml`, which can be a bit limiting for advanced use cases, you can instead write arbitray python code. By convention, the code lives next to the config file in a script called `parse.py` which needs a function called `parse`. This function takes 2 parameters: A flow run context and an extracted record from the source.

To transform the records within python and achieve the same result for the `gdho` dataset, an example script would look like this:

```python
from investigraph.util import make_proxy

def parse(ctx, record)
    proxy = make_proxy("Organization")
    proxy.id = record.pop("Id"))
    proxy.add("name", record.pop("Name"))
    # add more property data ...
    yield proxy
```

Now, remove the `mapping` key from the `config.yml` to implicitly tell **investigraph** to use this python script instead.

After it, test the pipeline again:

    investigraph inspect ./datasets/gdho/config.yml --transform

