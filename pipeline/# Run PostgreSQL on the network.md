# Run PostgreSQL on the network
docker run -it \
  -e POSTGRES_USER="postgres" \
  -e POSTGRES_PASSWORD="postgres" \
  -e POSTGRES_DB="ny_taxi" \
  -v ny_taxi_postgres_data:/var/lib/postgresql \

  -p 5432:5432 \
  --network=pg-network \
  --name pgdatabase \
  postgres:18  cat /workspaces/data-engineering/pipeline/WORKFLOW.md

# In another terminal, run pgAdmin on the same network
docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -v pgadmin_data:/var/lib/pgadmin \
  -p 8085:80 \
  --network=pg-network \
  --name pgadmin \
  dpage/pgadmin4