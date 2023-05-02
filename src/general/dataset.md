# Dataset

A specific **dataset** of a source with a clear scope, consisting of individual [entities](/general/entity). Example: "Company register of the Republic of Moldova" or "Lobby register of the German Bundestag". A dataset can either be a "one shot", i.e. generated only once, or incrementally updated (daily, weekly, monthly...) if the data source allows it.

Datasets can be part of a [data catalog](/general/catalog).

A dataset is found remotely as a `JSON` file that holds the [metadata](#metadata) and references resource files for the included data.

## examples

- European Commission - Meetings with interest representatives: [https://data.ftm.store/ec_meetings/index.json](https://data.ftm.store/ec_meetings/index.json)

## metadata

The dataset model for **investigraph** is adapted from the [nomenklatura](/stack/nomenklatura) library.

A dataset requires two properties, `name` and `title`, and a list of `resources`.

It usually has more metadata, including a summary and describing the publishing source.

The full metadata for the *EC meetings* example dataset:

```json
{
  "name": "ec_meetings",
  "title": "European Commission - Meetings with interest representatives",
  "summary": "The Commission applies strict rules on transparency concerning its contacts\nand relations with interest representatives: it requires all its Members, their\nclosest advisors (members of Cabinet) and all Directors-General to meet only\ninterest representatives that are registered in the Transparency Register and\nto publish information on such meetings. Those measures fall within the\nmeaning and scope of the conditionality and complementary transparency\nmeasures provided for in the Interinstitutional Agreement establishing the\nmandatory Transparency Register.",
  "updated_at": "2023-05-02T01:07:48",
  "resources": [
    {
      "name": "entities.ftm.json",
      "url": "https://data.ftm.store/ec_meetings/entities.ftm.json",
      "mime_type": "application/json+ftm",
      "mime_type_label": "FollowTheMoney Entities"
    }
  ],
  "children": [],
  "publisher": {
    "name": "European Commission Secretariat-General",
    "url": "https://commission.europa.eu/about-european-commission/departments-and-executive-agencies/secretariat-general_en",
    "description": "The Secretariat-General is responsible for the overall coherence of the\nCommission’s work – both in shaping new policies, and in steering them\nthrough the other EU institutions. It supports the whole Commission.",
    "official": false
  }
}
```
