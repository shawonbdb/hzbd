# apr/26/2021 00:10:06 by RouterOS 6.46.2
# software id = 1PNC-ULLU
#
# model = RB4011iGS+
# serial number = XXXXXXXXXXXX

/interface bridge
add comment=Local_LAN name=Local

/interface bridge port
add bridge=Local interface=ether4

/interface ethernet
set [ find default-name=ether1 ] comment=WAN01 mac-address=\
    XX:XX:XX:XX:XX:XX
set [ find default-name=ether2 ] comment=WAN02 mac-address=\
    XX:XX:XX:XX:XX:XX
set [ find default-name=ether3 ] comment=WAN03 mac-address=\
    XX:XX:XX:XX:XX:XX
set [ find default-name=ether4 ] comment="LAN"
set [ find default-name=sfp-sfpplus1 ] disabled=yes

/interface pppoe-client
add add-default-route=yes comment=PPPoE_WAN-01 disabled=no interface=ether1 \
    name=PPPOE_01 password=xxxx use-peer-dns=yes user=xxxx
add add-default-route=yes comment=PPPoE_WAN-02 disabled=no interface=ether2 \
    name=PPPOE_02 password=xxxx use-peer-dns=yes user=xxxx
add add-default-route=yes comment=PPPoE_WAN-03 disabled=no interface=ether3 \
    name=PPPOE_03 password=xxxx use-peer-dns=yes user=xxxx

/ip cloud
set ddns-enabled=yes ddns-update-interval=5m

/ip address
add address=192.168.66.1/24 interface=Local network=192.168.66.0

/ip pool
add name=dhcp_pool ranges=192.168.66.101-192.168.66.250
/ip dhcp-server
add address-pool=dhcp_pool disabled=no interface=Local lease-time=12h name=\
    dhcp1
/ip dhcp-server network
add address=192.168.66.0/24 gateway=192.168.66.1

/ip dns
set allow-remote-requests=yes

/ip firewall address-list
add address=192.168.66.101-192.168.66.254 list=Local
add address=127.0.0.1 disabled=yes list=allow-ip

/ip firewall filter
add action=reject chain=input comment="==== DDoS Attack Block ====" \
    dst-port=53 in-interface=ether1 protocol=tcp reject-with=\
    icmp-network-unreachable
add action=reject chain=input dst-port=53 in-interface=ether1 \
    protocol=udp reject-with=icmp-network-unreachable
add action=reject chain=input dst-port=53 in-interface=ether2 protocol=tcp \
    reject-with=icmp-network-unreachable
add action=reject chain=input dst-port=53 in-interface=ether2 protocol=udp \
    reject-with=icmp-network-unreachable
add action=reject chain=input dst-port=53 in-interface=ether3 protocol=tcp \
    reject-with=icmp-network-unreachable
add action=reject chain=input dst-port=53 in-interface=ether3 protocol=udp \
    reject-with=icmp-network-unreachable

/ip firewall nat
add action=masquerade chain=srcnat comment="====  ALL_SRCNAT  ====" \
    out-interface-list=all

/ip firewall mangle
add action=mark-connection chain=prerouting comment="Load Balance" \
    dst-address-list=!Local in-interface=Local new-connection-mark=\
    wan03_conn passthrough=yes per-connection-classifier=\
    both-addresses-and-ports:9/0 src-address-list=Local
add action=mark-connection chain=prerouting dst-address-list=!Local \
    in-interface=Local new-connection-mark=wan03_conn passthrough=yes \
    per-connection-classifier=both-addresses-and-ports:9/1 src-address-list=\
    Local
add action=mark-connection chain=prerouting dst-address-list=!Local \
    in-interface=Local new-connection-mark=wan03_conn passthrough=yes \
    per-connection-classifier=both-addresses-and-ports:9/2 src-address-list=\
    Local
add action=mark-connection chain=prerouting dst-address-list=!Local \
    in-interface=Local new-connection-mark=wan02_conn passthrough=yes \
    per-connection-classifier=both-addresses-and-ports:9/3 src-address-list=\
    Local
add action=mark-connection chain=prerouting dst-address-list=!Local \
    in-interface=Local new-connection-mark=wan02_conn passthrough=yes \
    per-connection-classifier=both-addresses-and-ports:9/4 src-address-list=\
    Local
add action=mark-connection chain=prerouting dst-address-list=!Local \
    in-interface=Local new-connection-mark=wan02_conn passthrough=yes \
    per-connection-classifier=both-addresses-and-ports:9/5 src-address-list=\
    Local
add action=mark-connection chain=prerouting dst-address-list=!Local \
    in-interface=Local new-connection-mark=wan01_conn passthrough=yes \
    per-connection-classifier=both-addresses-and-ports:9/6 src-address-list=\
    Local
add action=mark-connection chain=prerouting dst-address-list=!Local \
    in-interface=Local new-connection-mark=wan01_conn passthrough=yes \
    per-connection-classifier=both-addresses-and-ports:9/7 src-address-list=\
    Local
add action=mark-connection chain=prerouting dst-address-list=!Local \
    in-interface=Local new-connection-mark=wan01_conn passthrough=yes \
    per-connection-classifier=both-addresses-and-ports:9/8 src-address-list=\
    Local
add action=mark-routing chain=prerouting connection-mark=wan03_conn \
    dst-address-list=!Local in-interface=Local new-routing-mark=wan03_route \
    passthrough=yes src-address-list=Local
add action=mark-routing chain=prerouting connection-mark=wan02_conn \
    dst-address-list=!Local in-interface=Local new-routing-mark=\
    wan02_route passthrough=yes src-address-list=Local
add action=mark-routing chain=prerouting connection-mark=wan01_conn \
    dst-address-list=!Local in-interface=Local new-routing-mark=wan01_route \
    passthrough=yes src-address-list=Local

add action=mark-routing chain=prerouting comment=Redirect_wan03_Local \
    new-routing-mark=wan03_Redirect_Local passthrough=yes src-address=\
    192.168.69.11-192.168.69.19
add action=mark-routing chain=prerouting comment=Redirect_wan01_Local \
    new-routing-mark=wan01_Redirect_Local passthrough=yes src-address=\
    192.168.69.21-192.168.69.29
add action=mark-routing chain=prerouting comment=Redirect_wan02_Local \
    new-routing-mark=wan02_Redirect_Local passthrough=yes src-address=\
    192.168.69.31-192.168.69.39

add action=mark-routing chain=prerouting comment=\
    "===  MAC Based Specific Redirection (From WAN01) ===" dst-address=\
    !192.168.66.0/24 in-interface=Local new-routing-mark=wan01_route \
    passthrough=yes src-mac-address=XX:XX:XX:XX:XX:XX
add action=mark-routing chain=prerouting comment=\
    "===  MAC Based Specific Redirection (From WAN02) ===" dst-address=\
    !192.168.66.0/24 in-interface=Local new-routing-mark=wan02_route \
    passthrough=yes src-mac-address=XX:XX:XX:XX:XX:XX
add action=mark-routing chain=prerouting comment=\
    "===  MAC Based Specific Redirection (From WAN03) ===" dst-address=\
    !192.168.66.0/24 in-interface=Local new-routing-mark=wan03_route \
    passthrough=yes src-mac-address=XX:XX:XX:XX:XX:XX

/ip route
add distance=1 gateway=WAN03-PPPOE routing-mark=wan03_route
add distance=1 gateway=WAN02-PPPOE routing-mark=wan02_route
add distance=1 gateway=WAN01-PPPOE routing-mark=wan01_route

/system identity
set name=MikroTik_Multiple-WAN

/tool bandwidth-server
set authenticate=no
