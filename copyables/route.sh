#!/bin/bash
function addip {
    alias=$1
    host=$2
    echo "gateway param $3"
    if [[ $host =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(\/[0-9]{1,2})?$ ]]; then
        echo 'IP_ADDRESS'
        ips=($host)
    else
        ipstring=`dig +short $host | grep '^[.0-9]*$'`
        ips=($ipstring)
    fi
    echo -e "\n$alias : $host : ${ips[@]}"
    for ip in "${ips[@]}"
    do
        echo "adding ip: ${ip}#"
        result=`ip route add ${ip} via ${GW} metric 0 dev ${TAP_DEVICE}`
        echo "add route for $alias: ip route add ${ip} via ${GW} dev ${TAP_DEVICE}: $result"
    done
}
if [ -e /root/route.txt ]; then
    echo 'Found /root/route.txt file. Will set-up routes through VPN'
    sed "s/\r//g" /root/route.txt | while read alias host; do
        addip ${alias} ${host}
    done
#    wait
else
    echo "!No /root/route.txt found. will try ROUTES env variable"
    if ! [ -z "${ROUTES}" ]; then
        echo "Using ROUTES env variable"
        for route in $(echo ${ROUTES} | sed "s/,/ /g")
        do
            echo "adding route to ${route}"
            addip custom ${route}
        done
    fi
fi