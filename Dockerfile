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
RUN wget -O- https://api.github.com/repos/dssg/weather2pgsql/tarball/481219bcea3f317616f4c7a65c02f2dcbdd96ff | \
    tar -zxf -

ENV BASE="/dssg-weather2pgsql-0b655a8"
WORKDIR "$BASE"

# copy config and database credentials
ADD default_profile "$BASE/"

# run script that creates database objects and loads data
RUN /bin/bash -c "./weather.sh"
