/*@bruin
name: reports.trips_report
type: duckdb.sql
connection: duckdb-default
depends:
  - staging.trips
materialization:
  type: table
  strategy: create+replace
columns:
  - name: pickup_date
    type: date
    description: Date of trips
  - name: taxi_type
    type: string
    description: Type of taxi (yellow, green)
  - name: total_trips
    type: integer
    description: Total number of trips
  - name: total_passengers
    type: integer
    description: Total passengers transported
  - name: avg_passengers
    type: float
    description: Average passengers per trip
  - name: total_distance
    type: float
    description: Total distance traveled in miles
  - name: avg_distance
    type: float
    description: Average trip distance in miles
  - name: total_fare
    type: float
    description: Total fare amount
  - name: avg_fare
    type: float
    description: Average fare per trip
  - name: total_tips
    type: float
    description: Total tip amount
  - name: total_revenue
    type: float
    description: Total revenue (fare + tips)
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
FROM staging.trips
GROUP BY DATE(pickup_datetime), taxi_type
ORDER BY pickup_date, taxi_type
