docker run -it --rm \
  -e POSTGRES_USER="postgres" \
  -e POSTGRES_PASSWORD="postgres" \
  -e POSTGRES_DB="ny_taxi" \
  -v ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  --network=pg-network \
  --name pgdatabase \
  postgres:16

  docker run -it --rm \
   taxi_ingest:v001 \
  --pg-user=postgres \
  --pg-password=postgres \
  --pg-host=pgdatabase \
  --pg-port=5432 \
  --pg-db=ny_taxi \
  --table-name=yellow_taxi_trips_2021_1 \
  --chunksize=100_000

docker run -it \
  --network=pipeline_pg-network \
  taxi_ingest:v001 \
    --pg-user=postgres \
    --pg-password=postgres \
    --pg-host=pgdatabase \
    --pg-port=5432 \
    --pg-db=ny_taxi \
    --table-name=yellow_taxi_trips_ \
    --year=2021 \
    --chunksize=100000



    uv run python ingest_data.py \
  --pg-user=postgres \
  --pg-password=postgres \
  --pg-host=localhost \
  --pg-port=5432 \
  --pg-db=ny_taxi \
  --table-name=yellow_taxi_trips_2021_1 \
  --year=2021 \
  --month=1 \
  --chunksize=100000