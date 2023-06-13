# Docker

For production usage, use the docker build and a persistent cache and database (aka [redis](https://redis.io) and [postgres](postgresql.org/)).

This allows to deploy the prefect server (and ui) seperated from one or more agents. Server and agent use the same image but with a different entrypoint.

[investigraph docker image](https://github.com/investigativedata/investigraph-etl/pkgs/container/investigraph)

## Environment

Example settings for production, using postgres and redis:

```
PREFECT_API_URL=http://server:4200/api
PREFECT_API_DATABASE_CONNECTION_URL=postgresql+asyncpg://investigraph:investigraph@postgres/investigraph
FTM_STORE_URI=postgresql://investigraph:investigraph@postgres/investigraph
REDIS_URL=redis://redis:6379
```

Store this as a file to use as `env_file` within compose.

## Example docker-compose.yml

This is a minimal production example using dedicated redis cache and persistent postgres database. Note that (as in the environment settings above) [ftmstore](https://github.com/alephdata/followthemoney-store) and prefect.io share the same database instance.

Scale worker agents via

    docker compose up --scale worker=4

Note that if you want to output result data to a file directory that should be shared (and visible from outside docker), add a volume mount to the agent service.


```yaml
version: "3.9"

services:
  redis:
    image: redis:latest

  postgres:
    image: postgres:15
    volumes:
      - db:/var/lib/postgresql
    environment:
      POSTGRES_PASSWORD: investigraph
      POSTGRES_USER: investigraph
      POSTGRES_DB: investigraph

  server:
    image: ghcr.io/investigativedata/investigraph:latest
    ports:
      - 127.0.0.1:4200:4200
    depends_on:
      - postgres
      - redis
    volumes:
      - data:/data/prefect
      - ./datasets:/data/local/datasets
    env_file:
      investigraph.env

  agent:
    image: ghcr.io/investigativedata/investigraph:latest
    command: prefect agent start -q 'default'
    depends_on:
      - server
    env_file:
      investigraph.env

volumes:
  db:
  data:
```
