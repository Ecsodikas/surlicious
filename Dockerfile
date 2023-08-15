FROM ubuntu:lunar AS build

RUN apt-get -y update && \
    apt-get -y install curl xz-utils build-essential libssl-dev && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /var/cache/apt

WORKDIR /opt

ENV DMD_MAJOR_VERSION=2 \
    DMD_MINOR_VERSION=105.0
ENV DMD_VERSION=$DMD_MAJOR_VERSION.$DMD_MINOR_VERSION

RUN curl https://downloads.dlang.org/releases/$DMD_MAJOR_VERSION.x/$DMD_VERSION/dmd.$DMD_VERSION.linux.tar.xz -o dmd.tar.xz && \
    tar xJf dmd.tar.xz && \
    rm dmd.tar.xz

ENV PATH=/opt/dmd2/linux/bin64:$PATH

WORKDIR /src
COPY . .
RUN dub build

CMD ["./surlicious"]
