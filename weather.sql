create schema if not exists weather;

create table if not exists weather.weather (
    usaf INTEGER NOT NULL,
    wban INTEGER NOT NULL,
    year INTEGER NOT NULL, 
    month VARCHAR(2) NOT NULL, 
    day VARCHAR(2) NOT NULL, 
    hour VARCHAR(2) NOT NULL, 
    air_temp_celsius real, 
    dew_point_temp_celsius real, 
    sea_level_pressure INTEGER, 
    wind_direction INTEGER, 
    wind_speed_km_hr real, 
    sky_condition_total_coverage_code INTEGER, 
    liquid_precipitation_mm_one_hour INTEGER, 
    liquid_precipitation_mm_six_hours INTEGER
);
