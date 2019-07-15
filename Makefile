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

import-db:
	cd $(IDEMPIERE_REPOSITORY)/org.adempiere.server-feature/data/seed/ && jar xvf Adempiere_pg.jar
	docker run --rm -it --network host -e PGPASSWORD=postgres postgres:9.6 psql -h localhost -q -U postgres -c "CREATE ROLE adempiere SUPERUSER LOGIN PASSWORD 'adempiere'"
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:9.6 createdb -h localhost --template=template0 -E UNICODE -O adempiere -U adempiere idempiere
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:9.6 psql -h localhost -d idempiere -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog"
	docker run --rm -it --network host -e PGPASSWORD=adempiere postgres:9.6 psql -h localhost -d idempiere -U adempiere -c 'CREATE EXTENSION "uuid-ossp"'
	cat $(IDEMPIERE_REPOSITORY)/org.adempiere.server-feature/data/seed/Adempiere_pg.dmp | docker run --rm -i --network host -e PGPASSWORD=adempiere postgres:9.6 psql -h localhost -d idempiere -U adempiere
	docker run --rm -it --network host -e PGPASSWORD=adempiere -v $(IDEMPIERE_REPOSITORY):/idempiere -v $(shell pwd):/scripts postgres:9.6 sh /scripts/syncApplied.sh
