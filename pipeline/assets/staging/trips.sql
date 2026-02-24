/*@bruin
name: staging.trips_bq
type: bq.sql
connection: gcp-default
depends:
  - ingestion.trips_bq
materialization:
  type: table
  strategy: create+replace
@bruin*/

SELECT
    pickup_datetime,
    dropoff_datetime,
    pickup_location_id,
    dropoff_location_id,
    taxi_type,
    passenger_count,
    trip_distance,
    payment_type,
    fare_amount,
    tip_amount,
    total_amount,
    extracted_at
FROM `composite-haiku-402317.ingestion.trips_bq`
WHERE pickup_datetime IS NOT NULL
    AND passenger_count > 0
    AND total_amount >= 0
