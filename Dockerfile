FROM debian:jessie

ENV DEVICE PIPE

# Install cpiped, note the sed command replaces the sample rate in cpiped to match snapcast
RUN apt-get update && apt-get install -y \
  build-essential \
  git \
  libasound2-dev \
  alsa-utils && \
  git clone https://github.com/b-fitzpatrick/cpiped.git && \
  cd cpiped && \
  sed -i 's/44100/48000/' cpiped.c && \
  make

# Set the entry point
ENTRYPOINT ["/init"]

# Install services
COPY services /etc/services.d

# Install init.sh as init script
COPY init.sh /etc/cont-init.d/

# Download and extract s6 init
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.19.1.1/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

