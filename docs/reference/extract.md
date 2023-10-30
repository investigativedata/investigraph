# extract.py

Bring your own code to the extraction stage.

The entrypoint function must yield dictionaries that will be passed as records to the next stage to transform.

### let investigraph fetch your sources

#### config.yml

```yaml
extract:
  sources:
    - uri: https://example.com/data.csv
  handler: ./extract.py:handle
```

#### extract.py

```python
import csv
from io import StringIO
from typing import Any, Generator

from investigraph.model import Context, Resolver

def handle(ctx: Context, res: Resolver) -> Generator[dict[str, Any], None, None]:
    content = res.get_content()
    yield from csv.DictReader(StringIO(content))
```

### fetch by yourself

#### config.yml

```yaml
extract:
  sources:
    - uri: https://example.com/data.csv
  handler: ./extract.py:handle
  fetch: false
```

#### extract.py

```python
import requests
from typing import Any, Generator

from investigraph.model import Context

def handle(ctx: Context) -> Generator[dict[str, Any], None, None]:
    res = requests.get(ctx.source.uri)
    for record in res.json():
        yield record["item"]
```
