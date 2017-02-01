#!/usr/bin/env bash

# Downloads hourly weather data for a given station
# Find the codes and available dates at ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv

# Inputs:
#
#  1) Directory name
#  2) US Air Force weather-station code
#  3) WBAN weather-station code
#  4) Set Postgres environment variables or .pgpass

# Output:



# Check for their existence
if [ $# -lt 3 ]
then
  echo "Three arguments required"
  exit 1
fi

#  1. Directory Name where you'll store the data
DIRNAME=$1
#  2. USAF code
USAF=$2
#  3. WBAN code 
WBAN=$3
 

# grab beginning and ending years for the given station
(cd $DIRNAME && wget -N 'ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv')
begin=$(cat ${DIRNAME}/isd-history.csv | grep -E "${USAF}.*${WBAN}" | cut -d, -f10 | cut -c2-5)
end=$(cat ${DIRNAME}/isd-history.csv | grep -E "${USAF}.*${WBAN}" | cut -d, -f11 | cut -c2-5)


# download the zipped files
parallel -j200% '(wget -N -P {1} "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/{4}/{2}-{3}-{4}.gz")' ::: $DIRNAME ::: $USAF ::: $WBAN ::: $(seq $begin $end)


# unzip
gunzip -c ${DIRNAME}/*.gz | sed 's/-9999/     /g' | in2csv -H -s weather_schema.csv | sed 's/,-,/,,/g' |
csvsql --query "select year, month, day, hour, air_temp/10.0 as air_temp_celsius, dew_point_temp/10.0 as dew_point_temp_celsius, \
sea_level_pressure, wind_direction, .36*wind_speed_rate as wind_speed_km_hr, sky_condition_total_coverage_code, \
liquid_precipitation_depth_dimension_one_hour as liquid_precipitation_mm_one_hour, \
liquid_precipitation_depth_dimension_six_hours as liquid_precipitation_mm_six_hours from stdin;" > ${DIRNAME}/weather_master.csv

# create Postgres schema and table and load data there
if [ $(grep 'copy weather' weather.sql | wc -l) -eq "0" ]; 
  then echo "\copy weather.weather from '${DIRNAME}/weather_master.csv' with csv header;" >> weather.sql;
fi
psql -v ON_ERROR_STOP=1 -f weather.sql
