The use of dlt (Data Load Tool) provides a complete data pipeline to ingest, store, and 
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


### Question 2. What proportion of trips are paid with credit card?

```sql
SELECT 
    payment_type,
    COUNT(*) AS trip_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM rides
GROUP BY payment_type
ORDER BY trip_count DESC;
```

Result: 26.66%


### Question 3. What is the total amount of money generated in tips?

```sql
SELECT 
    ROUND(SUM(tip_amt), 3) AS total_tips
FROM rides;
```

Result: $6,063.41

Screenshot of the SQL query using the marimo notebook.

<img width="997" height="921" alt="image" src="https://github.com/user-attachments/assets/01ba42e3-86c0-4711-a1d6-903a92040a33" />


