FROM waggle/plugin-base:1.1.1-base

RUN apt-get update \
  && apt-get install -y \
  stress-ng \
  hdparm \
  iperf3 \
  redis
