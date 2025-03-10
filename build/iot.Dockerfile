FROM alpine:3.10

# Update repositories for Alpine 3.10
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.10/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.10/community" >> /etc/apk/repositories && \
    apk update

# Install specific vulnerable package versions
RUN apk add --no-cache --force-overwrite \
    mosquitto=1.6.3-r0 \
    vsftpd=3.0.3-r6 \
    openssh=8.1_p1-r0 \
    openssh-server=8.1_p1-r0 \
    cups=2.2.12-r1 \
    busybox-extras=1.30.1-r5 \
    live-media \
    live-media-utils

RUN apk add --no-cache \
    sudo \
    bash \
    # CoAP
    libcoap \
    # Supervisor
    supervisor \
    && rm -rf /var/cache/apk/*

USER root

# SSH Setup
RUN ssh-keygen -A && \
    passwd -d root
COPY containers/iot/sshd/sshd_config /etc/ssh/sshd_config
RUN chmod +rwx /etc/ssh/sshd_config
RUN echo "pts/0" >> /etc/securetty

# FTP Setup
COPY containers/iot/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf
RUN sed -i 's,\r,,;s, *$,,' /etc/vsftpd/vsftpd.conf
ADD containers/iot/vsftpd/secret.txt /secret.txt

# Mosquitto Configuration
ADD containers/iot/mosquitto/mosquitto.conf /etc/mosquitto/mosquitto.conf

# Telnet Setup
ADD containers/iot/inetd/inetd.conf /etc/inetd/inetd.conf

# RTSP
RUN mkdir -p /var/media/rtsp && \
    wget -O /var/media/rtsp/sample.mp4 "http://distribution.bbb3d.renderfarming.net/video/mp4/bbb_sunflower_1080p_30fps_normal.mp4" && \
    chmod -R 755 /var/media/rtsp
WORKDIR /usr/local/bin
RUN wget -O mediamtx.tar.gz "https://github.com/bluenviron/mediamtx/releases/download/v1.11.3/mediamtx_v1.11.3_linux_amd64.tar.gz" && \
    tar -xzf mediamtx.tar.gz && \
    rm mediamtx.tar.gz
COPY containers/iot/rtsp/mediamtx.yml /etc/mediamtx.yml
COPY containers/iot/rtsp/start-rtsp.sh /start-rtsp.sh
RUN chmod +x /start-rtsp.sh

# CUPS Setup
COPY containers/iot/cups/cupsd.conf /etc/cups/cupsd.conf
RUN sed -i 's/^#FileDevice No/FileDevice Yes/' /etc/cups/cups-files.conf

# Supervisor Setup
RUN mkdir -p /etc/supervisor/conf.d /var/log/supervisor
ADD containers/iot/supervisor/ /etc/supervisor/conf.d/
ADD containers/iot/supervisord.conf /etc/supervisor/supervisord.conf

COPY containers/iot/post.sh /post.sh
RUN chmod +x /post.sh

ENTRYPOINT ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
