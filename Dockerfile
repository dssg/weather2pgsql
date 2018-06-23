# download and store hourly NOAA weather data for a given US state

FROM ubuntu:16.04

RUN apt update && \
    apt install -y wget \
                   parallel \
                   postgresql \
                   python3-pip

# install csvkit
RUN pip3 install --upgrade pip && \
    pip3 install csvkit

# clone repo
RUN wget -O- https://api.github.com/repos/dssg/weather2pgsql/tarball/def03b91c8082b760f119f080965f92c8c2d40f1 | \
    tar -zxf -

ENV BASE="/dssg-weather2pgsql-def03b9"
WORKDIR "$BASE"

# copy config and database credentials
ADD default_profile "$BASE/"

# run script that creates database objects and loads data
RUN /bin/bash -c "./weather.sh"
