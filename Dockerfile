# download and store hourly NOAA weather data for a given US state

FROM ubuntu:14.04

RUN apt-get update && \
    apt-get install -y wget \
                       git \
                       postgresql \
                       parallel \
                       python3-pip

# install csvkit
RUN pip3 install --upgrade pip && \
    pip3 install csvkit

# clone repo
RUN git clone https://github.com/dssg/weather2pgsql.git

ENV BASE="/weather2pgsql"
WORKDIR "$BASE"

# copy config and database credentials
ADD default_profile "$BASE/"

# run script that creates database objects and loads data
RUN /bin/bash -c "./weather.sh"
