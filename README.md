# NOAA_weather
Download NOAA weather for a user-specified station

Input requirements:

1. Directory name where you will store the output 
2. US Air Force weather-station code
3. WBAN weather-station code

You can find the weather-station codes [here](ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.txt).

To download weather data for Chicago's Midway Airport,
```
./weather_download.sh /mnt/data/jwalsh/weather/ 725340 14819
```

Software requirements:
* bash
* [`parallel`](https://www.gnu.org/software/parallel/)
