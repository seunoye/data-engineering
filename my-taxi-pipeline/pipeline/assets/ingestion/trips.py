"""@bruin

name: ingestion.trips
type: python
image: python:3.11
connection: duckdb-default

materialization:
  type: table
  strategy: append

columns:
  - name: vendor_id
    type: integer
    description: TPEP provider code (1=Creative Mobile, 2=VeriFone)
  - name: pickup_datetime
    type: timestamp
    description: Date and time when meter was engaged
  - name: dropoff_datetime
    type: timestamp
    description: Date and time when meter was disengaged
  - name: passenger_count
    type: integer
    description: Number of passengers in the vehicle
  - name: trip_distance
    type: float
    description: Trip distance in miles
  - name: pickup_location_id
    type: integer
    description: TLC Taxi Zone pickup location ID
  - name: dropoff_location_id
    type: integer
    description: TLC Taxi Zone dropoff location ID
  - name: payment_type
    type: integer
    description: Payment method code
  - name: fare_amount
    type: float
    description: Time-and-distance fare calculated by the meter
  - name: tip_amount
    type: float
    description: Tip amount (auto-populated for credit card payments)
  - name: total_amount
    type: float
    description: Total amount charged to passengers
  - name: taxi_type
    type: string
    description: Type of taxi (yellow, green)
  - name: extracted_at
    type: timestamp
    description: Timestamp when data was extracted

@bruin"""

import os
import json
import pandas as pd
from datetime import datetime


def materialize():
    """Fetch NYC taxi trip data for the given date window."""
    
    # Get Bruin runtime context
    start_date = os.environ.get("BRUIN_START_DATE", "2022-01-01")
    end_date = os.environ.get("BRUIN_END_DATE", "2022-01-31")
    
    # Get pipeline variables (taxi_types)
    bruin_vars = json.loads(os.environ.get("BRUIN_VARS", '{"taxi_types": ["yellow"]}'))
    taxi_types = bruin_vars.get("taxi_types", ["yellow"])
    
    # Parse dates to generate year-month combinations
    start = datetime.strptime(start_date, "%Y-%m-%d")
    end = datetime.strptime(end_date, "%Y-%m-%d")
    
    all_data = []
    extracted_at = datetime.now()
    
    # Generate URLs for each taxi type and month in the date range
    current = start
    while current <= end:
        year_month = current.strftime("%Y-%m")
        
        for taxi_type in taxi_types:
            url = f"https://d37ci6vzurychx.cloudfront.net/trip-data/{taxi_type}_tripdata_{year_month}.parquet"
            
            try:
                df = pd.read_parquet(url)
                
                # Standardize column names (yellow vs green taxi have different schemas)
                df = df.rename(columns={
                    "VendorID": "vendor_id",
                    "tpep_pickup_datetime": "pickup_datetime",
                    "lpep_pickup_datetime": "pickup_datetime",
                    "tpep_dropoff_datetime": "dropoff_datetime",
                    "lpep_dropoff_datetime": "dropoff_datetime",
                    "passenger_count": "passenger_count",
                    "trip_distance": "trip_distance",
                    "PULocationID": "pickup_location_id",
                    "DOLocationID": "dropoff_location_id",
                    "payment_type": "payment_type",
                    "fare_amount": "fare_amount",
                    "tip_amount": "tip_amount",
                    "total_amount": "total_amount"
                })
                
                # Select and add metadata columns
                columns_to_keep = [
                    "vendor_id", "pickup_datetime", "dropoff_datetime",
                    "passenger_count", "trip_distance", "pickup_location_id",
                    "dropoff_location_id", "payment_type", "fare_amount",
                    "tip_amount", "total_amount"
                ]
                df = df[[c for c in columns_to_keep if c in df.columns]]
                df["taxi_type"] = taxi_type
                df["extracted_at"] = extracted_at
                
                all_data.append(df)
                print(f"Fetched {len(df)} records for {taxi_type} {year_month}")
                
            except Exception as e:
                print(f"Failed to fetch {taxi_type} {year_month}: {e}")
        
        # Move to next month
        if current.month == 12:
            current = current.replace(year=current.year + 1, month=1)
        else:
            current = current.replace(month=current.month + 1)
    
    if all_data:
        return pd.concat(all_data, ignore_index=True)
    
    return pd.DataFrame()


