# Question 1: Install Spark and PySpark

# install spark
    wget https://dlcdn.apache.org/spark/spark-3.5.8/spark-3.5.8-bin-hadoop3.tgz
# unpact it
    tar xvfz spark-3.5.8-bin-hadoop3.tgz

Setting up PySpark
Copy Java and Spark to .bashrc
      
    nano .bashrc

    export JAVA_HOME="${HOME}/05-batch_processing/jdk-11.0.1"
    export PATH="${JAVA_HOME}/bin:${PATH}"

    export SPARK_HOME="${HOME}/05-batch_processing/spark-3.5.8-bin-hadoop3"
    export PATH="${SPARK_HOME}/bin:${PATH}"


  # Question 2: Read the November 2025 Yellow into a Spark Dataframe.
  Repartition the Dataframe to 4 partitions and save it to parquet.
  What is the average size of the Parquet (ending with .parquet extension) 
  Files that were created (in MB)? Select the answer which most closely matches.

      df = spark.read \
        .option("header", "true") \
        .parquet('yellow_tripdata_2025-11.parquet')

      df = df.repartition(4)
      df.write.parquet('yellow_tripdata/2025/11/')
    
  <img width="1083" height="355" alt="image" src="https://github.com/user-attachments/assets/1da6add2-6957-4163-af48-527fcb7ac631" />

  # Question 3: Count records

    How many taxi trips were there on the 15th of November? Consider only trips that started on the 15th of November
    
    records_count = spark.sql("""
    SELECT
        COUNT(*)
    FROM df_trips_data
    WHERE pickup_datetime BETWEEN '2025-11-15 00:00:00' AND '2025-11-15 23:59:59'
    """)
    records_count.show()

    # Result:  162604

 # Question 4: Longest trip
    # What is the length of the longest trip in the dataset in hours?
    df_result = spark.sql("""
    SELECT
        MAX((unix_timestamp(dropoff_datetime) - unix_timestamp(pickup_datetime)) / 3600.0) AS longest_trip_hours
    FROM df_trips_data
    WHERE pickup_datetime IS NOT NULL
    AND dropoff_datetime IS NOT NULL
    AND dropoff_datetime >= pickup_datetime
    """)
    df_result.show()

    Result: 90.646667

# Question 5: User Interface
Spark's User Interface, which shows the application's dashboard, runs on which local port?

Results: Spark UI runs on ports 4040 and 4041, from my experience.


Question 6: Least frequent pickup location zone

    # Least frequent pickup location zone
    df_trips_data.createOrReplaceTempView("yellow_tripdata_2025_11")
    zones.createOrReplaceTempView("taxi_zone_lookup")

    df_least_frequent = spark.sql("""
    SELECT
        z.Zone,
        COUNT(*) AS pickup_count
    FROM yellow_tripdata_2025_11 t
    JOIN taxi_zone_lookup z
    ON t.PULocationID = z.LocationID
    GROUP BY z.Zone
    ORDER BY pickup_count ASC
    LIMIT 1
    """)
    df_least_frequent.show()

    Result: Governor's Island/Ellis Island/Liberty Island
    
