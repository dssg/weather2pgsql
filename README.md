# weather2postgres
This repository contains code to load two NOAA weather datasets into a Postgres database:

1. A dataset of all the weather stations the NOAA [Integrated Surface Database](https://www.ncdc.noaa.gov/isd) (ISD) has tracked
2. ISD's complete history of hour-by-hour readings for a user-specified US state

The script creates a Postgres schema called `weather`, a table for weather-station data called `weather.weather_stations`,
and a table for weather data called `weather.weather`. The script modifies some of the data to meet standard conventions. For example,
ISD reports temperatures in Celsius times 10; the script divides that column by 10 and adds `_celsius` to the column name.

To run: 

1. Copy `default_profile_example` to `default_profile` and modify with your database credentials (including database role, which is typically your username) preferred location.
2. Build the docker image: `docker build -t "weather:latest" .`

If you'd like data for multiple states, you can build images for each.

Software requirements:
* [docker](https://www.docker.com/)
