create schema if not exists weather;

drop table if exists weather.weather_stations;

CREATE TABLE weather.weather_stations (
    usaf CHAR(6) NOT NULL, 
    wban CHAR(5) NOT NULL, 
    station_name VARCHAR(175), 
    ctry VARCHAR(4), 
    state VARCHAR(4), 
    icao VARCHAR(5), 
    lat FLOAT, 
    lon FLOAT, 
    elevation_meters FLOAT, 
    begin_date DATE NOT NULL, 
    end_date DATE NOT NULL
);

\copy weather.weather_stations from weather_stations.csv with csv header;
