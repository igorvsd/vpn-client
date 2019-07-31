#!/bin/bash
function addip {
    alias=$1
    host=$2
    gw=$3
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
        addip ${alias} ${host} ${2}
    done
#    wait
else
    echo "!No /root/route.txt found."
fi