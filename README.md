# dez-week1-homework
DTC Data Engineering Zoomcamp Week 1 Homework Repository

# Question 1.
docker run -it --entrypoint "bash" python:3.12.8
pip --version

# Question 2.
Ran the code in docker-compose.yaml to come to the conlusion that both db:5432 and postgres:5432 are the corect options

# Prepare postgres
## create Network
docker network create pg-network

## postgres image in network
docker run -it \
-e POSTGRES_USER="root" \
-e POSTGRES_PASSWORD="root" \
-e POSTGRES_DB="ny_taxi" \
-v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
-p 5432:5432 \
--network=pg-network \
--name pg-database \
postgres:17-alpine

## pdAdmin image in network
docker run -it \
-e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
-e PGADMIN_DEFAULT_PASSWORD="root" \
-p 8080:80 \
--network=pg-network \
--name pgadmin \
dpage/pgadmin4

docker build -t taxi_ingest:v001 .

URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz"

docker run -it \
  --network=pg-network \
  taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=pg-database \
    --port=5432 \
    --db=ny_taxi \
    --table_name=green_taxi_trips \
    --url=${URL}

URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv"

docker run -it \
  --network=pg-network \
  taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=pg-database \
    --port=5432 \
    --db=ny_taxi \
    --table_name=taxi_zone_lookup \
    --url=${URL}

# Question 3
SELECT COUNT(*) AS record_count \
FROM green_taxi_trips \
WHERE lpep_pickup_datetime >= '2019-10-01' \
AND lpep_pickup_datetime < '2019-11-01' \
AND lpep_dropoff_datetime >= '2019-10-01' \
AND lpep_dropoff_datetime < '2019-11-01' \
AND trip_distance <= 1;

104802

SELECT COUNT(*) AS record_count \
FROM green_taxi_trips \
WHERE lpep_pickup_datetime >= '2019-10-01' \
AND lpep_pickup_datetime < '2019-11-01' \
AND lpep_dropoff_datetime >= '2019-10-01' \
AND lpep_dropoff_datetime < '2019-11-01' \
AND trip_distance > 1 \
AND trip_distance <= 3; \

198924

SELECT COUNT(*) AS record_count \
FROM green_taxi_trips \
WHERE lpep_pickup_datetime >= '2019-10-01' \
AND lpep_pickup_datetime < '2019-11-01' \
AND lpep_dropoff_datetime >= '2019-10-01' \
AND lpep_dropoff_datetime < '2019-11-01' \
AND trip_distance > 3 \
AND trip_distance <= 7; 

109603

SELECT COUNT(*) AS record_count \
FROM green_taxi_trips \
WHERE lpep_pickup_datetime >= '2019-10-01' \
AND lpep_pickup_datetime < '2019-11-01' \
AND lpep_dropoff_datetime >= '2019-10-01' \
AND lpep_dropoff_datetime < '2019-11-01' \
AND trip_distance > 7 \
AND trip_distance <= 10; \

27678

SELECT COUNT(*) AS record_count \
FROM green_taxi_trips \
WHERE lpep_pickup_datetime >= '2019-10-01' \
AND lpep_pickup_datetime < '2019-11-01' \
AND lpep_dropoff_datetime >= '2019-10-01' \
AND lpep_dropoff_datetime < '2019-11-01' \
AND trip_distance > 10; \

35189

# Question 4
SELECT lpep_pickup_datetime \
FROM green_taxi_trips \
WHERE trip_distance = (SELECT MAX(trip_distance) FROM green_taxi_trips); \

2019-10-31 23:23:41

# Question 5
SELECT z."Zone", SUM(t."total_amount") AS sum_total \
FROM green_taxi_trips t \
LEFT OUTER JOIN taxi_zone_lookup z ON t."PULocationID" = z."LocationID" \
WHERE DATE(t."lpep_pickup_datetime") = '2019-10-18' \
GROUP BY z."Zone" \
HAVING SUM(t."total_amount") > 13000 \
ORDER BY sum_total DESC;


# Question 6
SELECT z."Zone" AS drop_off_zone, MAX(t."tip_amount") AS largest_tip \
FROM green_taxi_trips t \
LEFT OUTER JOIN taxi_zone_lookup z ON t."DOLocationID" = z."LocationID" \
WHERE DATE(t."lpep_pickup_datetime") BETWEEN '2019-10-01' AND '2019-10-31' \
  AND EXISTS ( \
    SELECT 1 \
    FROM taxi_zone_lookup zp \
    WHERE zp."Zone" = 'East Harlem North' AND t."PULocationID" = zp."LocationID" \
  ) \
GROUP BY z."Zone" \
ORDER BY largest_tip DESC \
LIMIT 1;

# Question 7
Used the main.tf file to confirm the answer
