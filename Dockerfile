FROM ubuntu:latest

RUN apt-get update --allow-insecure-repositories
RUN apt-get install -y --no-install-recommends wget
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y --no-install-recommends ca-certificates
RUN apt-get install -y --no-install-recommends tzdata
RUN wget --no-check-certificate https://master.dl.sourceforge.net/project/d-apt/files/d-apt.list -O /etc/apt/sources.list.d/d-apt.list
RUN apt-get update --allow-insecure-repositories && apt-get -y --allow-unauthenticated install --reinstall d-apt-keyring
RUN apt-get update --allow-insecure-repositories \
 && apt-get install -y --no-install-recommends --allow-unauthenticated dmd-compiler dub libcurl4-gnutls-dev libevent-dev libssl-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt \

WORKDIR /src
COPY . .
