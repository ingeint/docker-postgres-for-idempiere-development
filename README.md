# PosgreSQL docker for iDempiere development

## Getting start

Configure the `IDEMPIERE_REPOSITORY` env variable in `~/.zshrc` or `~/.bashrc`.

Example:
```
IDEMPIERE_REPOSITORY=/home/sauljp/Workspace/idempiere
export IDEMPIERE_REPOSITORY
```

Or running `make set-idempiere-path value=/home/sauljp/Workspace/idempiere`

First time run `make run ; sleep 15 ; make import-db` or `make phoenix ; sleep 15 ; make import-db`.

If you are using `make phoenix` you need to run after `make import-db` each time.

## Envs

- `IDEMPIERE_REPOSITORY` need it
- `DOCKER_NAME` default `postgres`
- `POSTGRES_VERSION` default 9.6

## Commands

- Create a postgres container with volume: `make` or `make run`
- Create a postgres without volume: `make phoenix`
- Set env IDEMPIERE_REPOSITORY: `make set-idempiere-path value=/home/sauljp/Workspace/idempiere`
- Set env DOCKER_NAME: `make set-docker-name value=postgres`
- Set env POSTGRES_VERSION: `make set-postgres-version value=9.6`
- Stop postgres: `make stop`
- Restart postgres: `make start`
- See status: `make status`
- Open a bash: `make bash`
- Open psql: `make psql`
- Import db (includes `import-seed` and `migrate`): `make import-db`
- Import just the db seed: `make import-seed`
- Migrate: `make migrate`
- Create a backup: `make backup-db`
- Restore a db: `make restore-db filename=filename`
- Remove data volume: `make clean`
- Remove env variables: `make clean -env`
