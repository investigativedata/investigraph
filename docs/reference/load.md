# load.py

Bring your own code to the loading stage.

It takes `nomenklatura.entity.CompositeEntity` proxies coming from the transform stage.

It is called for each chunk of transformed proxies.

#### config.yml

```yaml
load:
  handler: ./load.py:handle
```

#### load.py

```python
import orjson
import sys

from typing import Any, Iterable
from nomenklatura.entity import CE
from investigraph.model import Context

def handle(ctx: Context, proxies: Iterable[CE]):
    for proxy in proxies:
        sys.stdout.write(orjson.dumps(proxy.to_dict()))
```
