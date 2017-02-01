# NOAA_weather
Download hourly NOAA data for a weather station, transform it, and load it into a Postgres database

Input requirements:

1. Directory name where you will store the output 
2. US Air Force weather-station code
3. WBAN weather-station code
4. Set Postgres [environment variables](https://www.postgresql.org/docs/9.5/static/libpq-envars.html)

You can find the weather-station codes [here](ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.txt).

To download weather data for Chicago's Midway Airport,
```
./weather_download.sh /mnt/data/jwalsh/weather/ 725340 14819
```

Software requirements:
* bash
* [csvkit](https://pypi.python.org/pypi/csvkit)
* [`parallel`](https://www.gnu.org/software/parallel/)
