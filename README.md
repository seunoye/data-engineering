NYC Taxi Pipeline — Documentation
A Complete Data Engineering Workflow with Bruin

Table of Contents
1.  Project Overview
2.  Architecture Diagram
3.  Project Structure
4.  Step-by-Step Workflow
5.  Asset Deep Dive
6.  How to Run
7.  Why Bruin for Data Engineering

Project Overview
The NYC Taxi Pipeline (my-taxi-pipeline) is a data engineering pipeline built with Bruin that:
-Ingests NYC Taxi & Limousine Commission (TLC) trip data from a public cloud source
-Stages the data with transformations and business logic
-Reports aggregated trip statistics for analysis
The pipeline uses DuckDB as the local analytical database, making it lightweight, fast, and fully portable.

Architecture Diagram


''' 
─────────────────────────────────────────────────────────┐
│                    NYC TAXI PIPELINE                     │
│                                                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │  INGESTION  │───▶│   STAGING   │───▶│   REPORTS   │  │
│  │   (Layer 1) │    │  (Layer 2)  │    │  (Layer 3)  │  │
│  └─────────────┘    └─────────────┘    └─────────────┘  │
│                                                         │
│  ● trips.py         ● trips.sql       ● trips_report   │
│    (Python)           (SQL Transform)   .sql            │
│                                         (SQL Aggregate) │
│  ● payment_lookup                                       │
│    (CSV Seed)                                           │
│                                                         │
│  ┌─────────────────────────────────────────────────────┐│
│  │              DuckDB (Local Warehouse)               ││
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  ││
│  │  │ingestion │  │ staging  │  │    reports        │  ││
│  │  │  .trips  │  │  .trips  │  │  .trips_report   │  ││
│  │  │  .payment│  │          │  │                   │  ││
│  │  │  _lookup │  │          │  │                   │  ││
│  │  └──────────┘  └──────────┘  └──────────────────┘  ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
'''

Project Structure

my-taxi-pipeline/
├── .bruin.yml                          # Global Bruin configuration
├── .gitignore
├── README.md
├── logs/                               # Pipeline execution logs
└── pipeline/
    ├── pipeline.yml                    # Pipeline definition & connections
    └── assets/
        ├── ingestion/                  # Layer 1: Raw data ingestion
        │   ├── trips.py               # Python asset — fetches TLC data
        │   ├── payment_lookup.asset.yml# CSV seed asset definition
        │   ├── payment_lookup.csv      # Reference data for payment types
        │   └── requirements.txt        # Python dependencies
        ├── staging/                    # Layer 2: Cleaned & transformed
        │   └── trips.sql              # SQL transformation asset
        └── reports/                   # Layer 3: Business-ready analytics
            └── trips_report.sql       # SQL aggregation asset


Step-by-Step Workflow

Step 1 — Configuration
File: .bruin.yml
This is the global Bruin configuration that defines environments and database connections.


File: pipeline/pipeline.yml
Defines the pipeline metadata, DuckDB connection, and scheduling.

# Key settings in pipeline.yml
name: nyc-taxi
schedule: daily

default_connections:
  duckdb: duckdb-default    # All assets use this DuckDB connection

💡 One config, one source of truth. No scattered connection strings across files.



Step 2 — Ingestion Layer
This layer pulls raw data from external sources into the ingestion schema.

2a. Trips Data (Python Asset)
File: pipeline/assets/ingestion/trips.py

|Property |	 Value |
|---------|--------|
|Type	|  Python  |
|Source	| NYC TLC CloudFront (Parquet files)|
|Strategy | create+replace (full refresh)|
|Output |  ingestion.trips |

What it does:

1. Reads BRUIN_START_DATE and BRUIN_END_DATE environment variables.
2. Falls back to January 2024 if the requested dates have no available data.
3. Downloads Parquet files from the NYC TLC public dataset.
4. Normalizes column names across yellow and green taxi schemas.
5. Samples 10,000 records per month/type to keep the dataset manageable.
6. Returns a Pandas DataFrame that Bruin loads into DuckDB.

Output columns:
| Column | Type | Description |
|--------|------|-------------|
| trip_id | string | unique indentifier per trip |
| taxi_type |string | yellow or green |
| pickup_datetime | datetime | When the trip started |
| dropoff_datetime | datetime | When the trip ended |
| passenger_count| integer | Number of passengers |
| extracted_at | datetime | When the data was extracted |

2b. Payment Lookup (CSV Seed Asset)
File: pipeline/assets/ingestion/payment_lookup.csv

| Property | Value |
|----------|-------|
| Type | CSV Seed |
| Strategy | replace (full refresh every run) |
| Output | ingestion.payment_lookup |
| Primary Key| payment_type_id |

What it does:
Loads a static reference table mapping payment type IDs to human-readable names.
Built-in quality checks:

| Check | Purpose |
|-------|---------|
| payment_type_id: not_null | No null primary keys |
| payment_type_id: unique	No | duplicate payment types |
| payment_type_name: not_null | Every type has a name |
💡 Data quality is a first-class citizen — checks run automatically after every load.

Step 3 — Staging Layer
File: pipeline/assets/staging/trips.sql

| Property | Value |
|----------|-------|
| Type | DuckDB SQL |
| Depends on | ingestion.trips |
| Output | staging.trips |

What it does:
Transforms raw ingested data into a cleaned, analysis-ready format. Typical transformations include:

- Data type casting
- Null handling
- Business logic application
- Column renaming for consistency

'''
    
    /* @bruin
    name: staging.trips
    type: duckdb.sql
    depends:
      - ingestion.trips
    @bruin */

    SELECT
        trip_id,
        taxi_type,
        pickup_datetime,
        dropoff_datetime,
        COALESCE(passenger_count, 0) AS passenger_count,
        extracted_at
    FROM ingestion.trips;
    
Dependency management is declarative — Bruin ensures ingestion.trips completes before staging.trips starts.

Step 4 — Reports Layer
File: pipeline/assets/reports/trips_report.sql

| Property | Value |
|----------|-------|
| Type | DuckDB SQL |
| Depends on | staging.trips |
| Output | reports.trips_report |

What it does:
Produces a final aggregated report with trip statistics grouped by taxi type and month.

'''

    /* @bruin
    name: reports.trips_report
    type: duckdb.sql
    depends:
      - staging.trips
    @bruin */

    SELECT
        taxi_type,
        DATE_TRUNC('month', pickup_datetime) AS trip_month,
        COUNT(*) AS total_trips,
        AVG(passenger_count) AS avg_passengers,
        MIN(pickup_datetime) AS earliest_pickup,
        MAX(pickup_datetime) AS latest_pickup
    FROM staging.trips
    GROUP BY taxi_type, DATE_TRUNC('month', pickup_datetime)
    ORDER BY trip_month, taxi_type;

Execution Flow Summary

bruin run
    │
    ├──▶ ingestion.payment_lookup   (CSV → DuckDB)
    │       └──▶ Quality Checks ✓
    │
    ├──▶ ingestion.trips            (Python → API → DuckDB)
    │
    ├──▶ staging.trips              (SQL transform, waits for ingestion.trips)
    │
    └──▶ reports.trips_report       (SQL aggregate, waits for staging.trips)
    
Parallel execution: ingestion.trips, and ingestion.payment_lookup run in parallel 
since they have no dependencies on each other.


## How to Run
Prerequisites

    # Install Bruin CLI
    brew install bruin-data/tap/bruin   # macOS
    # or
    curl -sSL https://raw.githubusercontent.com/bruin-data/bruin/main/install.sh | bash

 Run the Full Pipeline

    cd ~/bruin/my-taxi-pipeline/pipeline
    bruin run

 Run a Specific Asset

    bruin run assets/reports/trips_report.sql

Run with Custom Date Range

    bruin run \
    --start-date 2024-01-01T00:00:00Z \
    --end-date 2024-01-31T23:59:59Z
    
Validate Without Running

    bruin validate

Expected Output

    PASS ingestion.payment_lookup ...
    PASS ingestion.trips
    PASS staging.trips
    PASS reports.trips_report

    bruin run completed successfully in ~30s

    ✓ Assets executed      4 succeeded
    ✓ Quality checks       3 succeeded


# Why Bruin for Data Engineering

1. 🔀 Multi-Language Assets in One Pipeline
Bruin lets you mix Python and SQL assets seamlessly. No glue code needed.

| Need to call an API?  | → Write a Python asset |
|-----------------------|------------------------|
| Need to transform data? | → Write a SQL asset |
| Need a reference table? | → Drop in a CSV seed |

2. 📦 Zero Infrastructure
No Airflow. No Spark cluster. No Docker Compose. Just:

        bruin run
Bruin manages Python environments, dependencies, and execution order automatically.

3. 🔗 Declarative Dependencies
Dependencies are defined inside each asset file, not in a separate DAG definition:

       /* @bruin
       depends:
        - ingestion.trips
       @bruin */

Bruin builds the execution graph automatically and runs assets in the correct order with maximum parallelism.

4. ✅ Built-In Data Quality
Quality checks are embedded directly in asset definitions:

        columns:
        - name: payment_type_id
          checks:
          - name: not_null
          - name: unique
No need for a separate tool like Great Expectations or dbt tests.

5. 🏗️ Layered Architecture Out of the Box
Bruin naturally supports the medallion architecture pattern:

| Layer | Schema | Purpose |
|-------|--------|---------|
| Ingestion | ingestion | Raw data from external sources |
| Staging | staging | Cleaned & transformed data |
| Reports | reports | Business-ready aggregations |

6. 🔄 Environment Management
Switch between default (dev) and production with a single flag:

       bruin run --environment production
Connection strings, credentials, and configs swap automatically.

Bruin turns what would be a multi-tool, multi-service data platform into a single CLI command. 
For teams that need to move fast without sacrificing quality, it's a compelling choice
