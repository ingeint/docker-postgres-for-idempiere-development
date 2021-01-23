-include .env
export

ifeq ($(POSTGRES_VERSION),)
POSTGRES_VERSION := 12
endif

ifeq ($(DOCKER_NAME),)
DOCKER_NAME := postgres
endif

ifeq ($(DB_NAME),)
DB_NAME := idempiere
endif

run:
	docker run --name $(DOCKER_NAME) -d -e POSTGRES_PASSWORD=postgres -e TZ=America/Guayaquil -v postgres:/var/lib/postgresql/data -p 5432:5432 postgres:$(POSTGRES_VERSION)

set-idempiere-path:
	echo "IDEMPIERE_REPOSITORY=$(value)\nPOSTGRES_VERSION=$(POSTGRES_VERSION)\nDOCKER_NAME=$(DOCKER_NAME)\nDB_NAME=$(DB_NAME)\n" > .env

set-docker-name:
	echo "IDEMPIERE_REPOSITORY=$(IDEMPIERE_REPOSITORY)\nPOSTGRES_VERSION=$(POSTGRES_VERSION)\nDOCKER_NAME=$(value)\nDB_NAME=$(DB_NAME)\n" > .env

set-postgres-version:
	echo "IDEMPIERE_REPOSITORY=$(IDEMPIERE_REPOSITORY)\nPOSTGRES_VERSION=$(value)\nDOCKER_NAME=$(DOCKER_NAME)\nDB_NAME=$(DB_NAME)\n" > .env

set-db-name:
	echo "IDEMPIERE_REPOSITORY=$(IDEMPIERE_REPOSITORY)\nPOSTGRES_VERSION=$(POSTGRES_VERSION)\nDOCKER_NAME=$(DOCKER_NAME)\nDB_NAME=$(value)\n" > .env

phoenix:
	docker run --name $(DOCKER_NAME) -d -e POSTGRES_PASSWORD=postgres -e TZ=America/Guayaquil -p 5432:5432 postgres:$(POSTGRES_VERSION)

stop:
	docker stop $(DOCKER_NAME)

start:
	docker start $(DOCKER_NAME)

status:
	docker ps -a --filter "name=$(DOCKER_NAME)"

bash:
	docker run --rm -it --network host -e PGPASSWORD=postgres postgres:$(POSTGRES_VERSION) bash

psql:
	docker run --rm -it --network host -e PGPASSWORD=postgres postgres:$(POSTGRES_VERSION) psql -h localhost -U postgres

clean:
	docker rm -f $(DOCKER_NAME) || true
	docker volume rm postgres || true

clean-env:
	rm .env || true

import-db: import-seed migrate

import-seed:
	cd $(IDEMPIERE_REPOSITORY)/org.adempiere.server-feature/data/seed/ && jar xvf Adempiere_pg.jar
	docker run --rm -it --network host -e PGPASSWORD=postgres postgres:$(POSTGRES_VERSION) psql -h localhost -q -U postgres -c "CREATE ROLE adempiere SUPERUSER LOGIN PASSWORD 'adempiere'" || true
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:$(POSTGRES_VERSION) createdb -h localhost --template=template0 -E UNICODE -O adempiere -U adempiere $(DB_NAME)
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:$(POSTGRES_VERSION) psql -h localhost -d $(DB_NAME) -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog"
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:$(POSTGRES_VERSION) psql -h localhost -d $(DB_NAME) -U adempiere -c 'CREATE EXTENSION "uuid-ossp"'
	cat $(IDEMPIERE_REPOSITORY)/org.adempiere.server-feature/data/seed/Adempiere_pg.dmp | docker run --rm -i --network host -e PGPASSWORD=adempiere postgres:$(POSTGRES_VERSION) psql -h localhost -d $(DB_NAME) -U adempiere

migrate:
	docker run --rm -it --network host -e PGPASSWORD=adempiere -e IDEMPIERE_HOME=/idempiere -e ADEMPIERE_DB_NAME=$(DB_NAME) -e ADEMPIERE_DB_SERVER=localhost -e ADEMPIERE_DB_PORT=5432 -v $(IDEMPIERE_REPOSITORY):/idempiere postgres:$(POSTGRES_VERSION) sh /idempiere/org.adempiere.server-feature/utils.unix/postgresql/SyncDB.sh adempiere adempiere postgresql

backup-db:
	docker run --rm --network host -e PGPASSWORD=adempiere postgres:$(POSTGRES_VERSION) pg_dump -v -h localhost -U adempiere -b -Fc -d $(DB_NAME) > $(shell echo `date +%Y%m%d%H%M%S`)-$(DB_NAME)-dev.backup
	echo "Backups: " && ls -laht *.backup

drop-db:
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:$(POSTGRES_VERSION) dropdb  -h localhost -U adempiere $(DB_NAME) || true

restore-db:
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:$(POSTGRES_VERSION) dropdb  -h localhost -U adempiere $(DB_NAME) || true
	docker run --rm -it --network host -e PGPASSWORD=postgres postgres:$(POSTGRES_VERSION) psql -h localhost -q -U postgres -c "CREATE ROLE adempiere SUPERUSER LOGIN PASSWORD 'adempiere'" || true
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:$(POSTGRES_VERSION) createdb -h localhost --template=template0 -E UNICODE -O adempiere -U adempiere $(DB_NAME)
	docker run --rm --network host -v $(shell pwd)/$(filename):/$(filename) -e PGPASSWORD=adempiere postgres:$(POSTGRES_VERSION) pg_restore -v -h localhost -U adempiere -d $(DB_NAME) /$(filename)
