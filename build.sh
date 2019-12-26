#!/bin/bash
#version=2.0.0
echo -ne "Which version do you want to TAG? (\033[1;34mskip\033[0m/version): "
read tag
docker build -t vpn-client-route .
if [[ -z "${tag}" ]]; then
    version=latest
else
    version=${tag}
fi
docker tag vpn-client-route igorvsd/vpn-client-route:${version}
if [[ -z "${tag}" ]]; then
    echo 'skipping upload to docker hub'
    exit 0
fi
docker login
docker push igorvsd/vpn-client-route:${version}
