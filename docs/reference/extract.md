# extract.py

Bring your own code to the extraction stage.

The entrypoint function must yield dictionaries that will be passed as records to the next stage to transform.

### let investigraph fetch your sources

#### config.yml

```yaml
extract:
  sources:
    - url: https://example.com/data.csv
  handler: ./extract.py:handle
```

#### extract.py

```python
import csv
from io import StringIO
from typing import Any, Generator

from investigraph.model import Context
from investigraph.model.source import TResponse

def handle(ctx: Context, res: TResponse) -> Generator[dict[str, Any], None, None]:
    yield from csv.DictReader(StringIO(res.content))
```

### fetch by yourself

#### config.yml

```yaml
extract:
  sources:
    - url: https://example.com/data.csv
  handler: ./extract.py:handle
  fetch: false
```

#### extract.py

```python
import requests
from typing import Any, Generator

from investigraph.model.context import Context

def handle(ctx: Context) -> Generator[dict[str, Any], None, None]:
    res = requests.get(ctx.source.uri)
    for record in res.json():
        yield record["item"]
```
