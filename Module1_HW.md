# Module1 Home work for Docker & PostgreSQL

## Question 1: Understanding Docker images
Run Docker with the python:3.13 image. Use an entrypoint bash to interact with the container.
What version of pip is in the image?

```Docker
docker run -it --entrypoint=bash python:3.13 -c 'pip --version'
pip 25.3 from /usr/local/lib/python3.13/site-packages/pip (python 3.13)
```


## Question 2. Understanding Docker networking and Docker Compose
Given the following docker-compose.yaml, what is the hostname and port that pgadmin should use to connect to the PostgreSQL database?

```Docker
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432'
    volumes:
      - vol-pgdata:/var/lib/postgresql/data

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
      PGADMIN_DEFAULT_PASSWORD: "pgadmin"
    ports:
      - "8080:80"
    volumes:
      - vol-pgadmin_data:/var/lib/pgadmin

volumes:
  vol-pgdata:
    name: vol-pgdata
  vol-pgadmin_data:
    name: vol-pgadmin_data
```
### Answer: Postgres:5432



## Question 3. Counting short trips
For the trips in November 2025 (lpep_pickup_datetime between '2025-11-01' and '2025-12-01', exclusive of the upper bound), how many trips had a trip_distance of less than or equal to 1 mile?

```sql
SELECT COUNT(*) AS trip_count
FROM public.taxi_trips
WHERE lpep_pickup_datetime >= TIMESTAMP '2025-11-01'
  AND lpep_pickup_datetime <  TIMESTAMP '2025-12-01'
  AND trip_distance <= 1;
```
<img width="1877" height="893" alt="image" src="https://github.com/user-attachments/assets/380bc4d2-f512-4381-8442-5d038c08bfee" />
### Answer: Total Trip Count: 8,007



## Question 4. Longest trip for each day
Which was the pick-up day with the longest trip distance? Only consider trips with a trip_distance less than 100 miles (to exclude data errors).
Use the pick-up time for your calculations.

```sql
SELECT
    DATE(lpep_pickup_datetime) AS pickup_day,
    MAX(trip_distance) AS max_trip_distance
FROM public.taxi_trips
WHERE lpep_pickup_datetime >= DATE '2025-11-01'
  AND lpep_pickup_datetime <  DATE '2025-12-01'
  AND trip_distance < 100
GROUP BY pickup_day
ORDER BY max_trip_distance DESC
LIMIT 1;
```
<img width="1907" height="896" alt="image" src="https://github.com/user-attachments/assets/c882bd5b-4c6c-4564-8b3a-2d2b96a5cd91" />
### Answer: Pick-up day with the longest trip is 2025-11-14 with a maximum trip distance of 88.03 miles.


## Question 5. Biggest pickup zone
Which was the pickup zone with the largest total_amount (sum of all trips) on November 18th, 2025?

```sql
SELECT
    z."Zone" AS pickup_zone,
    SUM(t.total_amount) AS total_revenue
FROM public.taxi_trips t
JOIN public.zones z
  ON t."PULocationID" = z."LocationID"
WHERE t.lpep_pickup_datetime >= DATE '2025-11-18'
  AND t.lpep_pickup_datetime <  DATE '2025-11-19'
GROUP BY z."Zone"
ORDER BY total_revenue DESC
LIMIT 1;
```
<img width="1872" height="890" alt="image" src="https://github.com/user-attachments/assets/d99a409f-9f2b-4d65-bb8e-5ba08841ce6d" />

### Answer: East Harlem North.


## Question 6. Largest tip
For the passengers picked up in the zone named "East Harlem North" in November 2025, which was the drop-off zone that had the largest tip?
Note: it's tip, not trip. We need the name of the zone, not the ID.

```sql
SELECT
    dz."Zone" AS dropoff_zone,
    MAX(t.tip_amount) AS max_tip
FROM public.taxi_trips t
JOIN public.zones pz
  ON t."PULocationID" = pz."LocationID"
JOIN public.zones dz
  ON t."DOLocationID" = dz."LocationID"
WHERE pz."Zone" = 'East Harlem North'
  AND t.lpep_pickup_datetime >= DATE '2025-11-01'
  AND t.lpep_pickup_datetime <  DATE '2025-12-01'
GROUP BY dz."Zone"
ORDER BY max_tip DESC;
```
<img width="1885" height="938" alt="image" src="https://github.com/user-attachments/assets/8b6efdb9-ca9e-4914-90f5-0ae6fbada476" />
### Answer: Yorkville West with a maximum tip of $81.89.


## Question 7. Terraform Workflow
Which of the following sequences, respectively, describes the workflow for:

1. Downloading the provider plugins and setting up backend.
2. Generating proposed changes and auto-executing the plan.
3. Remove all resources managed by Terraform.

### Answer: terraform init, terraform apply -auto-approve, terraform destroy




