#!/bin/bash
set -e

# Downloads hourly weather data for a given state

# Inputs (defined in default_profile):
#
#  1) Two-letter state abbreviation
#  2) Set environment variables

# Output:
#  1) postgres schema `weather`
#  2) table for weather stations
#  3) table for weather


# load credentials
#source default_profile


##  WEATHER-STATION DATA  ##
############################

# download weather-station data
mkdir -p data
wget -N \
     -P 'data/' \
     'ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv'

# copy data into weather-station data
tr [:upper:] [:lower:] < data/isd-history.csv |
tr ' ' '_' | 
sed 's/""//g' |
csvsql --query "select substr('000000' || cast(usaf as text), -6, 6) as usaf, \
                       substr('00000' || cast(wban as text), -5, 5) as wban, \
                       station_name, \
                       ctry as country, \
                       state, \
                       icao, \
                       lat, \
                       lon, \
                       \"elev(m)\" as elevation_meters, \
                       date(substr(begin,1,4) || '-' || substr(begin,5,2) || '-' || substr(begin,7,2)) as begin_date, \
                       date(substr(end,1,4) || '-' || substr(end,5,2) || '-' || substr(end,7,2)) as end_date \
               from stdin;" > weather_stations.csv

psql -v ON_ERROR_STOP=1 <<< $(echo "set role $PGROLE;" | cat - weather_stations.sql)



##       WEATHER DATA     ##
############################

psql -v ON_ERROR_STOP=1 <<< $(echo "set role $PGROLE;" | cat - weather.sql)

if [[ ! -z "$STATE_ABBREV" ]]; then
  # grab beginning and ending years for the stations
  N_STATIONS=$(psql -t <<-END | sed -E 's/[A-Za-z ]+//g'
    set role $PGROLE; 
    select count(*) as freq from weather.weather_stations where state = '$STATE_ABBREV';
END
)
  echo $N_STATIONS
  for i in $(seq 1 "$N_STATIONS"); do
    STATION=$(psql <<-END | sed -E 's/[A-Za-z ]+//g'
      set role $PGROLE;
      \copy (select usaf, wban, extract(year from begin_date), extract(year from end_date) \
             from weather.weather_stations \
             where state = '$STATE_ABBREV' \
             limit 1 \
             offset $i-1) to stdout with csv;
END
)
    USAF=$(echo "$STATION" | cut -d',' -f1)
    WBAN=$(echo "$STATION" | cut -d',' -f2)
    BEGIN=$(echo "$STATION" | cut -d',' -f3)
    END=$(echo "$STATION" | cut -d',' -f4)
    echo "$USAF" "$WBAN" "$BEGIN" "$END"

    # download the zipped files
    parallel -j200% 'bash parallel.sh {1} {2} {3}' ::: ${USAF} ::: ${WBAN} ::: $(seq ${BEGIN} ${END})
  done
fi

# grab beginning and ending years for the given station
if [[ ! -z "$COUNTRY_ABBREV" ]]; then
  # grab beginning and ending years for the stations
  N_STATIONS=$(psql -t <<-END | sed -E 's/[A-Za-z ]+//g'
    set role $PGROLE;
    select count(*) as freq from weather.weather_stations where state = '$COUNTRY_ABBREV';
END
)
  echo $N_STATIONS
  for i in $(seq 1 "$N_STATIONS"); do
    STATION=$(psql <<-END | sed -E 's/[A-Za-z ]+//g'
      set role $PGROLE;
      \copy (select usaf, wban, extract(year from begin_date), extract(year from end_date) \
             from weather.weather_stations \
             where state = '$COUNTRY_ABBREV' \
             limit 1 \
             offset $i-1) to stdout with csv;
END
)
    USAF=$(echo "$STATION" | cut -d',' -f1)
    WBAN=$(echo "$STATION" | cut -d',' -f2)
    BEGIN=$(echo "$STATION" | cut -d',' -f3)
    END=$(echo "$STATION" | cut -d',' -f4)
    echo "$USAF" "$WBAN" "$BEGIN" "$END"

    # download the zipped files
    parallel -j200% 'bash parallel.sh {1} {2} {3}' ::: ${USAF} ::: ${WBAN} ::: $(seq ${BEGIN} ${END})
  done
fi
