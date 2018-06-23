# download and store hourly NOAA weather data for a given US state

FROM ubuntu:14.04

RUN apt-get update && \
    apt-get install -y wget \
                       parallel \
                       postgresql \
                       python3-pip

# install csvkit
RUN pip3 install --upgrade pip && \
    pip3 install csvkit

# clone repo
RUN wget -O- https://api.github.com/repos/dssg/weather2pgsql/tarball/962500057c989142f61f6fbcd15e5ced6db3f095 | \ 
    tar -zxf -

ENV BASE="/dssg-weather2pgsql-9625000"
WORKDIR "$BASE"

# copy config and database credentials
ADD default_profile "$BASE/"

# run script that creates database objects and loads data
RUN /bin/bash -c "./weather.sh"
