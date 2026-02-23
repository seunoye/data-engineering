/* @bruin

name: staging.trips
type: duckdb.sql
connection: duckdb-default

materialization:
  type: table
  strategy: create+replace

depends:
  - ingestion.trips
  - ingestion.payment_lookup

columns:
  - name: pickup_datetime
    type: timestamp
    description: Trip pickup timestamp
  - name: dropoff_datetime
    type: timestamp
    description: Trip dropoff timestamp
  - name: pickup_location_id
    type: integer
    description: Pickup location zone ID
  - name: dropoff_location_id
    type: integer
    description: Dropoff location zone ID
  - name: taxi_type
    type: string
    description: Type of taxi (yellow, green)
  - name: passenger_count
    type: integer
    description: Number of passengers
  - name: trip_distance
    type: float
    description: Trip distance in miles
  - name: payment_type
    type: integer
    description: Payment method code
  - name: payment_type_name
    type: string
    description: Payment method name from lookup
  - name: fare_amount
    type: float
    description: Base fare amount
  - name: tip_amount
    type: float
    description: Tip amount
  - name: total_amount
    type: float
    description: Total trip amount
  - name: extracted_at
    type: timestamp
    description: Data extraction timestamp

@bruin */

WITH source_data AS (
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
    FROM ingestion.trips
    WHERE pickup_datetime IS NOT NULL
        AND fare_amount >= 0
        AND total_amount >= 0
),

deduplicated_data AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                pickup_datetime, 
                dropoff_datetime, 
                pickup_location_id, 
                dropoff_location_id, 
                fare_amount
            ORDER BY extracted_at DESC
        ) AS row_num
    FROM source_data
)

SELECT 
    d.pickup_datetime,
    d.dropoff_datetime, 
    d.pickup_location_id, 
    d.dropoff_location_id,
    d.taxi_type, 
    d.passenger_count,  
    d.trip_distance,
    d.payment_type,
    COALESCE(p.payment_type_name, 'Unknown') AS payment_type_name,
    d.fare_amount,
    d.tip_amount,
    d.total_amount,
    d.extracted_at
FROM deduplicated_data d
LEFT JOIN ingestion.payment_lookup p
    ON d.payment_type = p.payment_type_id
WHERE d.row_num = 1
