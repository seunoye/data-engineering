I have an existing GCS Bucket, so I downloaded the Newyork Taxi data 2024(Jan - Jun) from the website into my existing GCS bucket using the Cloud Shell

    BUCKET="gs://` ny-taxi-data-oo"
    # 2. Loop through months 01 to 06
    for i in {01..06}; do
    URL="https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-${i}.parquet"
    
    FILE_NAME="yellow_tripdata_2024-${i}.parquet"
    echo "---------------------------------------"
    echo "Downloading month ${i}..."
    wget $URL -O $FILE_NAME
  
    # Check if the download was successful before trying to upload
    if [ $? -eq 0 ]; then
        echo "Uploading ${FILE_NAME} to GCS..."
        gsutil cp $FILE_NAME ${BUCKET}/
        
        echo "Cleaning up local file..."
        rm $FILE_NAME
    else
        echo "ERROR: Could not download month ${i}. It might not be released yet."
    fi
    done


BigQuery Setup
Creating an External Table 

    CREATE OR REPLACE EXTERNAL TABLE `composite-haiku-402317.nytaxi.external.yellow_tripdata_2024`
    OPTIONS (
    format = 'PARQUET',
    -- The asterisk (*) tells BigQuery to grab all 06 months
    uris = ['gs://ny-taxi-data-oo/yellow_tripdata_2024-*.parquet'],
    description = 'NYC Taxi Trip Data'
    );

Creating a Regular Table

    CREATE OR REPLACE TABLE `composite-haiku-402317.nytaxi.yellow_tripdata_2024` AS
    SELECT * FROM `composite-haiku-402317.nytaxi.external_yellow_tripdata_2024`;

Question 1: What is the count of records for the 2024 Yellow Taxi Data?

    --SELECT COUNT OF ALL RECORDS IN THE TABLE
    QUESTION 1 (20,332,093)
    SELECT COUNT(*)
    FROM `composite-haiku-402317.nytaxi.yellow_tripdata_2024`;

Question 2. Data read estimation
Write a query to count the distinct number of PULocationIDs across both tables in the dataset.
What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?

      ---QUESTION 2 (0 MB for the External Table)
    SELECT COUNT(PULocationID)
    FROM `composite-haiku-402317.nytaxi.external_yellow_tripdata_2024`
    WHERE tpep_pickup_datetime BETWEEN '2024-01-01' AND '2024-06-30';
    
    ---QUESTION 2 (155.12 MB for the Materialized Table)
    SELECT COUNT(PULocationID)
    FROM `composite-haiku-402317.nytaxi.yellow_tripdata_2024`
    WHERE tpep_pickup_datetime BETWEEN '2024-01-01' AND '2024-06-30';

Question 3. Understanding columnar storage
Write a query to retrieve the PULocationID from the table (not the external table) in BigQuery. 
Now write a query to retrieve the PULocationID and DOLocationID on the same table.


    ---QUESTION 3 -- This query will process 155.12MB
    SELECT PULocationID
    FROM `composite-haiku-402317.nytaxi.yellow_tripdata_2024`;

    --This query will process 310.24MB
    SELECT PULocationID, DOLocationID
    FROM `composite-haiku-402317.nytaxi.yellow_tripdata_2024`;


Question 4. Counting zero fare trips
How many records have a fare_amount of 0?

    --QUESTION 4 = 8333
    SELECT COUNT(fare_amount) 
    FROM `composite-haiku-402317.nytaxi.yellow_tripdata_2024`
    WHERE fare_amount = 0;


Question 5. Partitioning and clustering
What is the best strategy to make an optimized table in BigQuery if your query will always filter based 
on tpep_dropoff_datetime and order the results by VendorID (Create a new table with this strategy).

    --QUESTION 5 - Partition by tpep_dropoff_datetime and Cluster by VendorID
    -- CREATE A PARTITIONED & CLUSTERED TABLE (tpep_dropoff_datetime)
    CREATE OR REPLACE TABLE composite-haiku-402317.nytaxi.partitioned_clustered_yellow_tripdata_2024
    PARTITION BY DATE(tpep_dropoff_datetime)
    CLUSTER BY VendorID AS
    SELECT * FROM composite-haiku-402317.nytaxi.yellow_tripdata_2024;


Question 6. Partition benefits
Write a query to retrieve the distinct VendorIDs between tpep_dropoff_datetime 2024-03-01 and 2024-03-15 (inclusive)
Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table 
in the from clause to the partitioned table you created for question 5 and note the estimated bytes processed. 
What are these values?


    --Question 6 - 310.24 MB for the non-partitioned table and 26.84 MB for the partitioned table
   
    SELECT DISTINCT(VendorID)
    FROM `composite-haiku-402317.nytaxi.yellow_tripdata_2024`
    WHERE DATE (tpep_dropoff_datetime) BETWEEN '2024-03-01' AND '2024-03-15';



    SELECT DISTINCT(VendorID)
    FROM `composite-haiku-402317.nytaxi.partitioned_clustered_yellow_tripdata_2024`
    WHERE DATE (tpep_dropoff_datetime) BETWEEN '2024-03-01' AND '2024-03-15';


Question 7. External table storage
Where is the data stored in the External Table you created?

    Answer: BigQuery


Question 8. Clustering best practices
It is best practice in BigQuery to always cluster your data:

    Answer: True

Question 9. Understanding table scans
No Points: Write a SELECT count(*) query FROM the materialized table you created. How many bytes does it estimate will be read? Why?

    --Question 9 = 0 bytes
    SELECT COUNT(*)
    FROM `composite-haiku-402317.nytaxi.yellow_tripdata_2024`;

    Answer: The estimated data size is 0 bytes. BigQuery caches data and reports 0 bytes from previously saved data at no cost.
    



    

