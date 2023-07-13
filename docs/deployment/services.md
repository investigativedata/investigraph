# Services

For a production deployment, investigraph needs some different running services based on the [prefect.io](../../stack/prefect) deployment needs.

The use case for deploying investigraph as outlined here is a decentralized, multi-node scenario where workflows are triggered and scheduled via the server ui instead of the command line (which is often used within the investigraph documentation).

[See docker deployment](../docker/) for documentation on how to deploy the services outlined here within a docker environment.

## Prefect server

The prefect server manages workflow runs and state. It as well serves a user interface for configuration, adding [blocks](https://docs.prefect.io/latest/concepts/blocks/) and scheduling workflows. After [installing investigraph](../../install), you can spin up the server locally via

    prefect server start

The server dashboard (prefect ui) is now running at [http://localhost:4200](http://localhost:4200)

The [investigraph docker image](https://github.com/investigativedata/investigraph-etl/pkgs/container/investigraph) uses the server as the default entrypoint, so running the server as a docker container is as easy as:

    docker run ghcr.io/investigativedata/investigraph

[More about server via prefect.io documentation](https://docs.prefect.io/latest/host/)

## Prefect agent

investigraph needs one or several agents that will execute the workflows orchestrated by the server.

    prefect agent start -q "default"

where `-q` defines the queue to use (see prefect.io documentation)

These agents don't have access to local data located in the server. That's why in a distributed deployment investigraph is using [blocks](https://docs.prefect.io/latest/concepts/blocks/) to store dataset configuration.

If you still want to access local data in your environment, make sure that the agent has access to the directories, or, in a docker deployment, ensure the correct volume mounts.

The agent needs to know which server api to use which is controlled via the env var `PREFECT_API_URL` which defaults to [http://127.0.0.1:4200/api](http://127.0.0.1:4200/api).

    PREFECT_API_URL=http://my.prefect.server/api prefect agent start -q "other-queue"

[More about agents via prefect.io documentation](https://docs.prefect.io/latest/concepts/work-pools/)

## Database

Per default, prefect server uses a sqlite database located in the directory specified by `PREFECT_HOME`. This database stores configuration, deployments, flow runs, task states. For more scalable production setups a [PostgreSQL](https://www.postgresql.org/) database is recomended.

**Important** sql adapters need to be asynchronous, like [asyncpg](https://pypi.org/project/asyncpg/) for postgres.

    PREFECT_API_DATABASE_CONNECTION_URL=postgresql+asyncpg://investigraph:investigraph@postgres/investigraph

## Runtime cache (Redis)

Processed data is shared between tasks (and their agent workers) via a redis cache.

In local or developement mode (set via `DEBUG=1`), investigraph just uses [fakeredis](https://pypi.org/project/fakeredis/), but for scalable deployments you should use a real redis instance.

investigraph only needs the cache during runtime and mimics `GETDEL` for all fetching operations, so the cache doesn't have to be persistent and will be empty again after a sucessful flow run.

Specify the cache endpoint via env var `REDIS_URL`, e.g.:

    REDIS_URL=redis://redis:6379
