# Install

If you are not planning to use the [investigraph command-line](../reference/cli) and want to deploy via docker instead, you don't have to install investigraph on your computer locally. Refer to our [docker documentation](../deployment/docker)

Installing investigraph is needed for interactive developement of new dataset sources or local test runs, though.

It is highly recommended to use a [python virtual environment](https://learnpython.com/blog/how-to-use-virtualenv-python/) for installation.

investigraph ships as a python package and can easily be installed via pip (or any other package manager from the python ecosystem):

    pip install investigraph

After installation and all it's dependencies, check that it is working:

    investigraph --version

Upgrade the package to the latest version:

    pip install -U investigraph

Uninstall:

    pip uninstall investigraph

## Develop version

Active development is happening in the `develop` branch. You can directly install it via pip:

    pip install git+https://github.com/investigativedata/investigraph-etl.git@develop
