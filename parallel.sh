#!/bin/bash
set -e

USAF=$1
WBAN=$2
YEAR=$3

wget -O- \
     "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/${YEAR}/${USAF}-${WBAN}-${YEAR}.gz" |
gunzip -c |
in2csv -H -s weather_schema.csv |
sed 's/,-,/,,/g;s/-9999/     /g' |
csvsql --query "select $USAF as usaf, $WBAN as wban, year, month, day, hour, air_temp/10.0 as air_temp_celsius, \
                dew_point_temp/10.0 as dew_point_temp_celsius, sea_level_pressure, wind_direction, .36*wind_speed_rate as wind_speed_km_hr, \
                sky_condition_total_coverage_code, liquid_precipitation_depth_dimension_one_hour as liquid_precipitation_mm_one_hour, \
                liquid_precipitation_depth_dimension_six_hours as liquid_precipitation_mm_six_hours from stdin;" > data/weather_${USAF}_${WBAN}_${YEAR}.csv
psql <<-END
  set role $PGROLE; 
  \copy weather.weather from 'data/weather_${USAF}_${WBAN}_${YEAR}.csv' with csv header;
END
