FROM alpine:latest

RUN apk update --update-cache
RUN apk add --no-cache \
    sudo \
    bash \
    # MQTT
    mosquitto \
    # CoAP 
    libcoap \
    # SSH
    openssh \
    openssh-server \
    # IPP
    cups \
    # Supervisor
    supervisor \
     # Telnet & inetd
    busybox-extras \
    && rm -rf /var/cache/apk/*

# FTP 
COPY containers/iot/vsftpd/vsftpd.conf /etc/vsftpd.conf
RUN apk add vsftpd && \
  sed -i 's,\r,,;s, *$,,' /etc/vsftpd.conf && \
  cp /etc/vsftpd.conf /etc/vsftpd.conf.orig && \
  mkdir /srv/ftp

COPY --chown=ftp:ftp containers/iot/vsftpd/flag.txt /srv/ftp/ftp_flag.txt

# SSH
RUN ssh-keygen -A && \
  adduser -D iot && \
  echo "iot:iot" | chpasswd

# Mosquitto
ADD containers/iot/mosquitto/mosquitto.conf /var/conf/mosquitto.conf

# CUPS
COPY containers/iot/cups/cupsd.conf /etc/cups/cupsd.conf
RUN sed -i 's/^#FileDevice No/FileDevice Yes/' /etc/cups/cups-files.conf

COPY containers/iot/supervisor/telnet.conf /etc/supervisor/conf.d/telnet.conf
RUN echo "root:root" | chpasswd
RUN echo "pts/0" >> /etc/securetty
EXPOSE 23
RUN echo "FLAG{telnet_root_access}" > /root/.flag.txt



# Supervisor
RUN mkdir -p /etc/supervisor/conf.d
RUN /usr/bin/echo_supervisord_conf > /etc/supervisor/supervisord.conf
RUN sed -i -e "s/^nodaemon=false/nodaemon=true/" /etc/supervisor/supervisord.conf

ADD containers/iot/supervisor/ /etc/supervisor/conf.d/
RUN echo "[include]" >> /etc/supervisor/supervisord.conf
RUN echo "files=/etc/supervisor/conf.d/*.conf" >> /etc/supervisor/supervisord.conf

COPY containers/iot/post.sh /post.sh
RUN chmod +x /post.sh

ENTRYPOINT ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]