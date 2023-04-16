# MongoDB Replica Set

A Replica Set of MongoDB running in a Docker container

## Not For Production

The key motivation for this image is to have a **ready-made** replica set of MongoDB running inside docker container for CI tests and local development.

To run the container, execute the following command:

```shell
docker run -d -p 30303:30303 -p 30304:30304 -p 30305:30305 qoire/local-mongo-replica-set:v4.4.20-version.1
```

Wait for 30 to 35 seconds in order to properly start all database instances and replica-set initialization.

### Versioning

Versioning follows the scheme of `v<mongoDB semver>.version.<image version>`

## Configuration

Additionally, you can pass an env variable called `HOST` when running the container
to configure the replica's hostname in docker. By default, it uses `localhost`.

Once ready, the replica-set can be accessed using the following connection string:

```shell
mongodb://localhost:30303,localhost:30304,localhost:30305/?replicaSet=rs0&readPreference=primary&ssl=false
```

If you're connecting from your host machine, you might need to set a new alias within `/etc/hosts`:

```
# /etc/hosts
127.0.0.1 HOST # where HOST is the value passed as env variable to the container
```

### Aside on Configurations

If your usecase is like mine, connecting from the host machine for something
like `dockertest`, with default ports (27017) already occupied, the default
config should work for you. But if you'd like to run tests in parallel, then
you must setup the `docker run` such that each image is occupying a different
port on the host machine.

The replica sets Hostname and Port must match that of the host machines. So we
cannot for example do mappings such as `-p 30303:27017`. See
`task test_run_alt_port` for details.

Example:

```shell
docker run -d \
    -e "DB1_PORT=40303" \
    -e "DB2_PORT=40304" \
    -e "DB3_PORT=40305" \
    -p 40303:40303 \
    -p 40304:40304 \
    -p 40305:40305 \
    qoire/local-mongo-replica-set
```

Associated mongodb uri would be:

```shell
mongodb://localhost:40303,localhost:40304,localhost:40305/?replicaSet=rs0&readPreference=primary&ssl=false
```