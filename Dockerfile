# Jackett and OpenVPN, JackettVPN
FROM alpine

ENV DEBIAN_FRONTEND noninteractive
ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

WORKDIR /opt

RUN echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
RUN apk --no-cache add shadow

RUN usermod -u 99 nobody

# Make directories
RUN mkdir -p /blackhole /config/Jackett /etc/jackett

# Update and upgrade
RUN apk update && apk upgrade

#  install required packages
RUN apk add \
    wget \
    curl \
    gnupg \
    sed \
    openvpn \
    curl \
    moreutils \
    net-tools \
    dos2unix \
    kmod \
    iptables \
    ipcalc\
    grep \
    #libunwind8 \
    libunwind \
    #icu-devtools \
    icu-dev \
    #libcurl4 \
    #could not find replacement
    #liblttng-ust0 \
    #libssl1.0.0 \
    #libkrb5-3 \
    krb5-libs \
    #zlib1g \
    #zlib \
    tzdata

RUN rm -rf /tmp/* /var/tmp/*


# Install Jackett
RUN jackett_latest=$(curl --silent "https://api.github.com/repos/Jackett/Jackett/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
    && curl -o /opt/Jackett.Binaries.LinuxAMDx64.tar.gz -L https://github.com/Jackett/Jackett/releases/download/$jackett_latest/Jackett.Binaries.LinuxAMDx64.tar.gz \
    && tar -xvzf /opt/Jackett.Binaries.LinuxAMDx64.tar.gz \
    && rm /opt/Jackett.Binaries.LinuxAMDx64.tar.gz

VOLUME /blackhole /config

ADD openvpn/ /etc/openvpn/
ADD jackett/ /etc/jackett/

RUN chmod +x /etc/jackett/*.sh /etc/jackett/*.init /etc/openvpn/*.sh /opt/Jackett/jackett

EXPOSE 9117
CMD ["sh", "/etc/openvpn/start.sh"]
