# transform.py

Bring your own code to the transformation stage.

The entrypoint function must yield `nomenklatura.entity.CompositeEntity` proxies. It is called for each record coming from the extraction stage.

#### config.yml

```yaml
transform:
  handler: ./transform.py:handle
```

#### transform.py

```python
from typing import Any, Generator
from nomenklatura.entity import CE

from investigraph.model import Context

def handle(ctx: Context, record: dict[str, Any], ix: int) -> Generator[CE, None, None]:
    proxy = ctx.make_proxy("Organization")
    proxy.id = record.pop("Id"))
    proxy.add("name", record.pop("Name"))
    # add more property data ...
    yield proxy
```
