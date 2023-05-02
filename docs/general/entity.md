# Entity

A data point with defined properties and optional references to other entities. Typical entities are a *Person*, a *Company* or a *Payment*.

Example of three different entities: 1. a person with a name and date of birth, 2. a company with a location and date of incorporation, and 3. the description of the connection of this person and company: "Directorship" with a start and end date.

**investigraph** uses [Follow The Money](/stack/followthemoney) as the underlaying model and technology to deal with entities.

## example

Entities are often expressed as snippets of `JSON`, with three standard fields: a unique `id`, a specification of the type of the entity called `schema`, and a set of `properties`. `properties` are multi-valued and values are always strings.

```json
{
  "id": "1b38214f88d139897bbd13eabde464043d84bbf9",
  "schema": "Person",
  "properties": {
    "name": ["John Doe"],
    "nationality": ["us", "au"],
    "birthDate": ["1982"]
  }
}
```

Read more about it in the [Follow The Money introduction](https://followthemoney.tech/docs/)
