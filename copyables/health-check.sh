#!/bin/bash
GW=${GW:-"192.168.30.1"}
ping -c 1 -w 5 ${GW}
RETURN_VALUE=$?
exit ${RETURN_VALUE}