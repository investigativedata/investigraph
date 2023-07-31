# aggregate.py

Bring your own code to the aggregation stage.

The handler is called after all entities are extracted and transformed and is applied to *all* resulted entities at once.

#### config.yml

```yaml
aggregate:
  handler: ./aggregate.py:handle
```

#### aggregate.py

```python
from investigraph.model import Context
from investigraph.logic.aggregate import Aggregator, AggregatorResult

def in_db(ctx: Context, fragment_uris: list[str]) -> AggregatorResult:
    # fragment uris is a list of strings for all the generated fragments chunks
    # get the aggregator helper class:
    aggregator = Aggregator(ctx, fragment_uris)

    with ctx.config.dataset.coverage as coverage:  # use coverage collector
        proxies = []
        # iterate through the not yet aggregated fragments:
        for proxy in aggregator.get_fragments():
            # apply your custom aggregation logic
            # ...
            if aggregated:
                proxies.append(proxy)
                coverage.collect(proxy)  # for statistics

    # load final entities
    ctx.load_entities(proxies, serialize=True)
    # return number of fragments and collected statistics
    return aggregator.fragments, coverage.export()
```
