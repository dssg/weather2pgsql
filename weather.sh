#!/bin/bash
set -ev

# Downloads hourly weather data for a given state

# Inputs:
#
#  1) Directory name
#  2) Two-letter state abbreviation
#  3) Set Postgres environment variables or .pgpass

# Output:


# load credentials
source default_profile


#  WEATHER-STATION DATA  ##
############################

# download weather-station data
mkdir -p data
wget -N -P 'data/' 'ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv'


# create schema and tables for weather data
psql -v ON_ERROR_STOP=1 -f weather_stations.sql 
psql -v ON_ERROR_STOP=1 -f weather.sql


# copy data into weather-station data
tr [:upper:] [:lower:] < data/isd-history.csv |
tr ' ' '_' | 
sed 's/""//g' |
csvsql --query "select usaf, wban, station_name, ctry as country, state, icao, lat, lon, \"elev(m)\" as elevation_meters, \
    date(substr(begin,1,4) || '-' || substr(begin,5,2) || '-' || substr(begin,7,2)) as begin_date, \
    date(substr(end,1,4) || '-' || substr(end,5,2) || '-' || substr(end,7,2)) as end_date from stdin;" |
psql -v ON_ERROR_STOP=1 -c "\copy weather.weather_stations from stdin with csv header;"


# grab beginning and ending years for the given station
N_STATIONS=$(psql -tc "select count(*) as freq from weather.weather_stations where state = '$STATE_ABBREV';")
for i in $(seq 1 "$N_STATIONS");
do
  STATION=$(psql -c "\copy (select usaf, wban, extract(year from begin_date), extract(year from end_date) \
                            from weather.weather_stations \
                            where state = '$STATE_ABBREV' \
                            limit 1 \
                            offset $i-1) \
                     to stdout with csv;")
  USAF=$(echo "$STATION" | cut -d',' -f1)
  WBAN=$(echo "$STATION" | cut -d',' -f2)
  BEGIN=$(echo "$STATION" | cut -d',' -f3)
  END=$(echo "$STATION" | cut -d',' -f4)

  echo "$USAF" "$WBAN" "$BEGIN" "$END"  

  # download the zipped files
  parallel -j100% 'bash parallel.sh {1} {2} {3}' ::: "$USAF" ::: "$WBAN" ::: $(seq "$BEGIN" "$END")
done
