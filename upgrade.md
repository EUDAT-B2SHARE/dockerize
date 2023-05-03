# Upgrade guide for POSTGRESQL

From 9.6 to 13

**Step 1: Get a database dump**

With a running stack before upgrade:

```bash
docker-compose exec postgres pg_dump --blobs --clean --dbname="${DBNAME}" --username="${DBUSER}" | gzip > dumpfile.sql.gz
```

**Step 2: DELETE old db**

With a running stack before upgrade:

```bash
docker container ls --filter name=<COMPOSE_PROJECT_NAME>_postgres_1 --format {{.ID}}
```

Variable `COMPOSE_PROJECT_NAME` is define in the .env file of the project. If the env variable is not define, the default value is the name of the folder where the .yml file is built.

```bash
docker exec -i <CONTAINER ID POSTGRES> psql --user <B2SHARE_POSTGRESQL_USER> postgres -c 'DROP database <B2SHARE_POSTGRESQL_DBNAME>'
```

**Step 3: Upgrade postgres**

New version of postgres is defined in the `docker-compose.yml` file. Thus, you only need to run:

```bash
docker-compose up -d postgres
```

**Step 4: Recreate database**

With a running stack after upgrade:

Get ID of the recreated container (Same as in step 2):

```bash
docker container ls --filter name=<COMPOSE_PROJECT_NAME>_postgres_1 --format {{.ID}}
```

```bash
docker exec -i <CONTAINER ID POSTGRES> psql --user <B2SHARE_POSTGRESQL_USER> postgres -c 'CREATE database <B2SHARE_POSTGRESQL_DBNAME>'
```

**Step 5: Restore data**

With a running stack after upgrade:

```bash
# Uncompressed .sql file:
docker exec -i <CONTAINER ID> psql --user <B2SHARE_POSTGRESQL_USER> <B2SHARE_POSTGRESQL_DBNAME> < <ABSOLUTE_PATH_TO_DB_BACKUP>
# Gzip compressed .sql.gz file:
zcat <ABSOLUTE_PATH_TO_DB_BACKUP> | docker exec -i <CONTAINER ID> psql --user <B2SHARE_POSTGRESQL_USER> <B2SHARE_POSTGRESQL_DBNAME>
```

Now the database should be upgraded to version 13

**If there are issues** it is a good idea to reindex elasticsearch indices:

Get B2SHARE container ID:

```bash
docker container ls --filter name=<COMPOSE_PROJECT_NAME>_b2share_1 --format {{.ID}}
```

With container ID in hand, run:

```bash
docker exec -it <CONTAINER ID B2SHARE> bash
# These commands executed in B2SHARE container
b2share index destroy --force --yes-i-know
b2share index init --force
b2share index queue init purge

b2share index reindex --yes-i-know
b2share index run

```
