# vpn-client

SoftEther VPN Client with automatic routes

Required to be started with --privileged & --network host because it creates network interface and modifies local routes

Confirmed to work in linux. [Ubuntu 18.04.1]

can be started with this script:
```
#!/bin/bash
docker rm -f vpn-client
docker run -d -it \
--restart unless-stopped \
--privileged \
--network host \
 -e NIC_NAME="nic1" \
 -e ACCOUNT_USER="client" \
 -e VPN_SERVER="1.2.3.4" \
 -e VIRTUAL_HUB="VPN" \
 -e GW="192.168.31.1" \
 -e VIRTUAL_HUB="VPN" \
 -e ACCOUNT_PASSWORD="somesuperpassword" \
 -v ~/ips-to-route.txt:/root/route.txt \
--name=vpn-client igorvsd/vpn-client-route sh
```
ips-to-route.txt 
supports both DNS-names & ip addresses
format is "name ->TABS-> ip/dns
sample:

```
spotify.com			spotify.com
slideshare.net			slideshare.net
some-my-ip                     52.123.33.11
```

Optional ENV params:

TAP_IPADDR="192.168.31.8/24". not to use DHCP client and just use static IP  
SLEEP_BEFORE=5 # seconds to sleep before start vpn client (when you start multiple vpn client docker containers - they all uses same vpn daemon and you need to make pause in related containers to prevent errors)
