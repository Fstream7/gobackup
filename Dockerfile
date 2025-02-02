FROM alpine:latest
ARG VERSION=latest
RUN apk add \
  curl \
  ca-certificates \
  openssl \
  postgresql-client \
  mariadb-connector-c \
  mysql-client \
  redis \
  mongodb-tools \
  sqlite \
  # replace busybox utils
  tar \
  gzip \
  pigz \
  bzip2 \
  # there is no pbzip2 yet
  lzip \
  xz-dev \
  lzop \
  xz \
  # pixz is in edge atm
  zstd \
  # microsoft sql dependencies \
  libstdc++ \
  gcompat \
  icu \
  # support change timezone
  tzdata \
  && \
  rm -rf /var/cache/apk/*

WORKDIR /tmp
RUN wget https://aka.ms/sqlpackage-linux && \
    unzip sqlpackage-linux -d /opt/sqlpackage && \
    rm sqlpackage-linux && \
    chmod +x /opt/sqlpackage/sqlpackage

ENV PATH="${PATH}:/opt/sqlpackage"

# Install the influx CLI
ARG INFLUX_CLI_VERSION=2.7.3
RUN case "$(uname -m)" in \
      x86_64) arch=amd64 ;; \
      aarch64) arch=arm64 ;; \
      *) echo 'Unsupported architecture' && exit 1 ;; \
    esac && \
    curl -fLO "https://dl.influxdata.com/influxdb/releases/influxdb2-client-${INFLUX_CLI_VERSION}-linux-${arch}.tar.gz" \
         -fLO "https://dl.influxdata.com/influxdb/releases/influxdb2-client-${INFLUX_CLI_VERSION}-linux-${arch}.tar.gz.asc" && \
    tar xzf "influxdb2-client-${INFLUX_CLI_VERSION}-linux-${arch}.tar.gz" && \
    cp influx /usr/local/bin/influx && \
    rm -rf "influxdb2-client-${INFLUX_CLI_VERSION}-linux-${arch}" \
           "influxdb2-client-${INFLUX_CLI_VERSION}-linux-${arch}.tar.gz" \
           "influxdb2-client-${INFLUX_CLI_VERSION}-linux-${arch}.tar.gz.asc" \
           "influx" && \
    influx version

ADD install /install
RUN /install ${VERSION} && rm /install

CMD ["/usr/local/bin/gobackup", "run"]
