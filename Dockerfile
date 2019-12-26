FROM alpine:3.6
ENV LANG="en_US.UTF-8" \
    SOFTETHER_VERSION="v4.31-9727-beta" \
    FOLDER="v4.31-9727"
RUN addgroup -S softether && adduser -D -H softether -g 'softether' -G softether -s /bin/sh && \
    apk add --no-cache --virtual .build-deps \
      gcc make musl-dev ncurses-dev openssl-dev readline-dev wget && \
    wget --no-check-certificate -O - "https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/${SOFTETHER_VERSION}/softether-src-${SOFTETHER_VERSION}.tar.gz" | tar xzf - && \
    cd ${FOLDER} && \
    cp src/makefiles/linux_64bit.mak Makefile && \
    make && make install && make clean && \
    strip /usr/vpnclient/vpnclient && \
    apk del .build-deps && \
    apk add --no-cache --virtual .run-deps \
    libcap libcrypto1.0 libssl1.0 ncurses-libs readline su-exec bash iptables bind-tools dhcpcd && \
    cd .. && rm -rf /usr/vpnbridge /usr/bin/vpnbridge /usr/vpnserver /usr/bin/vpnserver /usr/bin/vpnclient ${FOLDER}
COPY copyables /root/
RUN chmod +x /root/entrypoint*.sh && chmod +x /root/route*.sh
WORKDIR /root
ENTRYPOINT ["/root/entrypoint.sh"]
