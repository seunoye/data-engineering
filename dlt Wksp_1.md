The use of DLT (Data Load Tool) provides a complete data pipeline to ingest, store, and 
analyze NYC taxi ride data with DuckDB as the destination.


dlt pipeline demonstrates how to:

- Extract paginated JSON data from a REST API.
- Transform the data automatically using dlt's schema inference.
- Load the data into a local DuckDB database.
- Analyze the data using SQL and interactive notebooks.

It is interesting to note that taxi ride data loaded via the dlt pipeline can be analysed through the Marimo notebook.

###  Question 1. What is the start date and end date of the dataset?

```sql
SELECT 
    MIN(trip_pickup_date_time) AS start_date,
    MAX(trip_dropoff_date_time) AS end_date
FROM rides;
```
Result: 2009-06-01 to 2009-07-01

