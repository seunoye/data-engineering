/*@bruin
name: reports.trips_report_bq
type: bq.sql
connection: gcp-default
depends:
  - staging.trips_bq
materialization:
  type: table
  strategy: create+replace
@bruin*/

SELECT
    DATE(pickup_datetime) AS pickup_date,
    taxi_type,
    COUNT(*) AS total_trips,
    SUM(passenger_count) AS total_passengers,
    ROUND(AVG(passenger_count), 2) AS avg_passengers,
    ROUND(SUM(trip_distance), 2) AS total_distance,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(SUM(fare_amount), 2) AS total_fare,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(SUM(tip_amount), 2) AS total_tips,
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM `composite-haiku-402317.staging.trips_bq`
GROUP BY DATE(pickup_datetime), taxi_type
ORDER BY pickup_date, taxi_type
