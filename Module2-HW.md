# Module2 Home Work - Kestra Workflow Orchestration

## Question 1: What is the uncompressed file size (i.e. the output file yellow_tripdata_2020-12.csv of the extract task)?

To output the uncompressed file size, additional tasks were added to the flow to log the file size.

'''yaml

    - id: get_file_size
    type: io.kestra.plugin.core.storage.Size
    uri: "{{render(vars.data)}}"

    -id: log_file_size
    type: io.kestra.plugin.scripts.shell.Commands
    commands:
    - echo "file size for {{ inputs.taxi }} taxi data ({{ inputs.year }}-{{ inputs.month }}):{{ outputs.get_file_size.size }} bytes"
  '''

### Flow execution 
<img width="927" height="607" alt="image" src="https://github.com/user-attachments/assets/daa4301d-28f2-4d32-8486-287d15fa68e1" />

### Output file size after execution
<img width="1482" height="916" alt="image" src="https://github.com/user-attachments/assets/ddfada3f-2647-4441-b54a-65c8424c7368" />
### Answer
134.5 MiB

## Question 2: What is the rendered value of the variable file when the input taxi is set to green, year is set to 2020, and month is set to 04 during execution?
<img width="952" height="613" alt="image" src="https://github.com/user-attachments/assets/57030c36-e7a7-4532-9fd2-f78ecd60af28" />

<img width="1460" height="743" alt="image" src="https://github.com/user-attachments/assets/8e70772f-fcd8-4ee9-b4a5-7c0e1d406f4f" />
{{outputs.extract.outputFiles[inputs.taxi ~ '_tripdata_' ~ inputs.year ~ '-' ~ inputs.month ~ '.csv']}}

### Answer
{{inputs.taxi}}_tripdata_{{inputs.year}}-{{inputs.month}}.csv


## Question 3. How many rows are there in the Yellow Taxi data for all CSV files in 2020?

'''SQL
SELECT
    'yellow_tripdata_2020_01' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_01`
UNION ALL

SELECT
    'yellow_tripdata_2020_02' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_02`
UNION ALL

SELECT
    'yellow_tripdata_2020_03' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_03`
UNION ALL

SELECT
    'yellow_tripdata_2020_04' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_04`
UNION ALL

SELECT
    'yellow_tripdata_2020_05' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_05`
UNION ALL
SELECT
    'yellow_tripdata_2020_05_ext' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_05_ext`
UNION ALL
SELECT
    'yellow_tripdata_2020_06' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_06`
UNION ALL
SELECT
    'yellow_tripdata_2020_06_ext' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_06_ext`
UNION ALL
SELECT
    'yellow_tripdata_2020_07' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_07`
UNION ALL

SELECT
    'yellow_tripdata_2020_08' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_08`
UNION ALL

SELECT
    'yellow_tripdata_2020_09' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_09`
UNION ALL

SELECT
    'yellow_tripdata_2020_10' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_10`
UNION ALL

SELECT
    'yellow_tripdata_2020_11' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_11`
UNION ALL

SELECT
    'yellow_tripdata_2020_12' AS table_name,
    COUNT(*) AS total_rows
  FROM
    `composite-haiku-402317.ny_taxi.yellow_tripdata_2020_12`

'''
    





  

  








