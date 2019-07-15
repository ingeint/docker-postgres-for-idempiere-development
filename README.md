# PosgreSQL docker for iDempiere development

## Getting start

Configure the `IDEMPIERE_REPOSITORY` env variable in `~/.zshrc` or `~/.bashrc`.

Example:
```
IDEMPIERE_REPOSITORY=/home/sauljp/Workspace/idempiere
export IDEMPIERE_REPOSITORY
```

`make run ; sleep 15 ; make import-db` or `make phoenix ; sleep 15 ; make import-db`.

## Commands

- Run postgres with volume: `make` or `make run`
- Run postgres without volume: `make phoenix`
- Stop postgres: `make stop`
- See status: `make status`
- Open a bash: `make bash`
- Open psql: `make psql`
- Import db: `make import-db`

## Docker stacks

docker-stack with volume:
```yml
version: '3.7'

services:
  postgres:
    image: postgres:9.6
    volumes:
      - postgres:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=postgres
      - TZ=America/Guayaquil
    ports:
      - 5432:5432

volumes:
  postgres:
```

docker-stack without volume:
```yml
version: '3.7'

services:
  postgres:
    image: postgres:9.6
    environment:
      - POSTGRES_PASSWORD=postgres
      - TZ=America/Guayaquil
    ports:
      - 5432:5432
```
