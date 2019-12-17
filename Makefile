run:
	docker stack deploy -c docker-stack.yml postgres

phoenix:
	docker stack deploy -c docker-stack-no-volume.yml postgres

stop:
	docker stack rm postgres

status:
	docker stack services postgres

bash:
	docker run --rm -it --network host -e PGPASSWORD=postgres postgres:9.6 bash

psql:
	docker run --rm -it --network host -e PGPASSWORD=postgres postgres:9.6 psql -h localhost -U postgres

clean:
	@ docker volume rm postgres_postgres || true

import-db:
	cd $(IDEMPIERE_REPOSITORY)/org.adempiere.server-feature/data/seed/ && jar xvf Adempiere_pg.jar
	docker run --rm -it --network host -e PGPASSWORD=postgres postgres:9.6 psql -h localhost -q -U postgres -c "CREATE ROLE adempiere SUPERUSER LOGIN PASSWORD 'adempiere'"
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:9.6 createdb -h localhost --template=template0 -E UNICODE -O adempiere -U adempiere idempiere
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:9.6 psql -h localhost -d idempiere -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog"
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:9.6 psql -h localhost -d idempiere -U adempiere -c 'CREATE EXTENSION "uuid-ossp"'
	cat $(IDEMPIERE_REPOSITORY)/org.adempiere.server-feature/data/seed/Adempiere_pg.dmp | docker run --rm -i --network host -e PGPASSWORD=adempiere postgres:9.6 psql -h localhost -d idempiere -U adempiere
	docker run --rm -it --network host -e PGPASSWORD=adempiere -v $(IDEMPIERE_REPOSITORY):/idempiere -v $(shell pwd):/scripts postgres:9.6 sh /scripts/syncApplied.sh

backup-db:
	docker run --rm --network host -e PGPASSWORD=adempiere postgres:9.6 pg_dump -v -h localhost -U adempiere -b -Fc -d idempiere > $(shell echo `date +%Y%m%d%H%M%S`).backup

restore-db:
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:9.6 dropdb  -h localhost -U adempiere idempiere
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:9.6 createdb -h localhost --template=template0 -E UNICODE -O adempiere -U adempiere idempiere
	docker run --rm --network host -v $(shell pwd)/$(f):/$(f) -e PGPASSWORD=adempiere postgres:9.6 pg_restore -v -h localhost -U adempiere -d idempiere /$(f)
