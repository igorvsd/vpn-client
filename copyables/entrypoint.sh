#!/bin/bash
VIRTUAL_HUB=${VIRTUAL_HUB:-"VPN"}
NIC_NAME=${NIC_NAME:-"nic"}
GW=${GW:-"192.168.30.1"}
VPN_PORT=${VPN_PORT:-"5555"}
uid=`cat /proc/sys/kernel/random/uuid | cut -c 1-8`
ACCOUNT_NAME=${ACCOUNT_NAME:-"${uid}"}
ACCOUNT_USER=${ACCOUNT_USER:-"user"}
VPNCMD="vpncmd localhost /CLIENT /CMD"

SLEEP_BEFORE=${SLEEP_BEFORE:-"1"}

sleep ${SLEEP_BEFORE}
/usr/vpnclient/vpnclient start

sleep 2

${VPNCMD} NicCreate ${NIC_NAME}
${VPNCMD} NicEnable ${NIC_NAME}
${VPNCMD} AccountCreate ${ACCOUNT_NAME} /SERVER:${VPN_SERVER}:${VPN_PORT} /HUB:${VIRTUAL_HUB} /USERNAME:${ACCOUNT_USER} /NICNAME:${NIC_NAME}
if ! [ -z "${ACCOUNT_PASSWORD}" ]; then
    echo '!using password auth method'
    ${VPNCMD} AccountPasswordSet ${ACCOUNT_NAME} /PASSWORD:${ACCOUNT_PASSWORD} /TYPE:standard
else
    if [ -e /root/user.crt ]; then
        echo '!using certificate auth method'
        ${VPNCMD} AccountCertSet ${ACCOUNT_NAME} /LOADCERT:/root/sync.cer /LOADKEY:/root/sync.key
    else
        echo 'no password specified. should be set ENV value ACCOUNT_PASSWORD for using password method.'
        echo 'and no certificate specified. should be mounted to /root/user.crt and /root/user.key using docker volume method'
        exit 1
    fi
fi
#${VPNCMD} AccountDetailSet ${ACCOUNT_NAME} /MAXTCP:8 /NOQOS /INTERVAL:1 /TTL:0 /HALF:no /BRIDGE:no /MONITOR:no /NOTRACK:yes

if ! [ -z "${COMPRESS}" ]; then
    ${VPNCMD} AccountCompressEnable ${ACCOUNT_NAME}
fi

${VPNCMD} AccountConnect ${ACCOUNT_NAME}

export TAP_DEVICE="vpn_${NIC_NAME}"

while true; do
    if [ -e /sys/class/net/${TAP_DEVICE} ]
    then
        break
    else
        echo "waiting for device ${TAP_DEVICE} to be created"
        sleep 1
    fi
done

if [[ -z "${TAP_IPADDR}" ]]; then
    dhcpcd -G ${TAP_DEVICE}
else
    ip addr add ${TAP_IPADDR} dev ${TAP_DEVICE}
fi

ip route add ${GW}/32 via ${GW} dev ${TAP_DEVICE}

tail -F /usr/vpnclient/client_log/*.log &

startDate=`date +%s`
echo ${startDate}

while true; do
    ping -c 1 ${GW}
    rc=$?
    if [[ ${rc} -eq 0 ]] ; then
        break
    fi
    time=`date +%s`
    if [ $(($time-$startDate)) -gt 250 ]; then
      echo "ip ${GW} can't be reached. timeout 250sec"
      exit 1
    fi
    sleep 1
done

./route.sh

echo "VPN Client connected successfully. Starting infinite cycle to keep docker running."

trap 'echo "trap"; exit 0' SIGTERM SIGINT SIGKILL

while true; do sleep 1; done