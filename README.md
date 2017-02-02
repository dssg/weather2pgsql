# weather2postgres
This code downloads, modifies, and loads two NOAA weather datasets into a Postgres database:

1. A dataset of all the weather stations the NOAA [Integrated Surface Database](https://www.ncdc.noaa.gov/isd) (ISD) has tracked
2. ISD's complete history of hour-by-hour readings for one user-specified weather station

The script creates a Postgres schema called `weather`, a table for weather-station data called `weather.weather_stations`,
and a table for weather data called `weather.weather`. The script modifies some of the data to meet standard conventions. For example,
ISD reports temperatures in Celsius times 10; the script divides that column by 10 and adds `_celsius` to the column name.

Input requirements:

1. Directory name where you will store the output 
2. US Air Force weather-station code
3. WBAN weather-station code
4. Set Postgres [environment variables](https://www.postgresql.org/docs/9.5/static/libpq-envars.html)

You can find the weather-station codes [here](http://bit.ly/2kpCFcU).

To download weather data for Chicago's Midway Airport,
```
./weather_download.sh /mnt/data/jwalsh/weather/ 725340 14819
```

You can run the script multiple times for different airports. All the weather data get loaded into the `weather.weather` table. You can use the lat/long information in the `weather.weather_stations` table to identify the nearest weather station to any given point.

Software requirements:
* bash
* [csvkit](https://pypi.python.org/pypi/csvkit)
* [`parallel`](https://www.gnu.org/software/parallel/)
