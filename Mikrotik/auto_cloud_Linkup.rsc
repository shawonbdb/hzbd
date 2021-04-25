# apr/26/2021 00:10:06 by RouterOS 6.46.2
# software id = 1PNC-ULLU
#
# model = RB4011iGS+
# serial number = XXXXXXXXXXXX

/system script
add dont-require-permissions=no name=cloud_linkup owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    #####################################################################\r\
    \n###Identity: Cloud VPN Linkup\r\
    \n###Author: Shah Mohammad Shawon\r\
    \n###Created: August 03 2017\r\
    \n###Last Edited: May 03 2019\r\
    \n###Compatible Versions: ROS 6.x\r\
    \n###Tested on: ROS 6.2 - 6.42\r\
    \n######################################################################\r\
    \n\r\
    \n### Local variable initialization ### \r\
    \n:local myvar1 \"PPTPCLOUD\";\r\
    \n:local myvar2 \"L2TPCLOUD\";\r\
    \n:local myvar3 \"OVPNCLOUD\";\r\
    \n:local id \"xxxxxx\";\r\
    \n:local pass \"000000\";\r\
    \n:local pppServerDnsName \"mikrotik.shawon.com\";\r\
    \n:local l2tpinterface \"L2TP with Mikrotik_Cloud\";\r\
    \n:local pptpinterface \"PPTP with Mikrotik_Cloud\";\r\
    \n:local ovpninterface \"OVPN with Mikrotik_Cloud\";\r\
    \n:local l2tpdeconn \"disconnected\";\r\
    \n:local pptpdeconn \"disconnected\";\r\
    \n:local ovpndeconn \"disconnected\";\r\
    \n:global pppserverip;\r\
    \n:execute \":global \$myvar1 \$l2tpdeconn\";\r\
    \n:execute \":global \$myvar2 \$pptpdeconn\";\r\
    \n:execute \":global \$myvar3 \$ovpndeconn\";\r\
    \n:log warning (\"Start check for PPP connectivity\");\r\
    \n\r\
    \n\r\
    \n### Working Script ###\r\
    \n:if ([ :len \$pppserverip ] = 0 ) do={ :global pppserverip [:resolve \"\
    \$pppServerDnsName\"] }\r\
    \n:local current [:resolve \"\$pppServerDnsName\"];\r\
    \n:log warning (\"\$pppserverip\" . \" vs \" . \"\$current\");\r\
    \n\r\
    \n\r\
    \n\r\
    \n#connectivity check\r\
    \n:if ([/interface pptp-client get \$pptpinterface running]=true) do={\r\
    \n\t:log warning \"\$pptpinterface is running perfectly\";\r\
    \n\t:set pptpdeconn \"connected\";\r\
    \n\t:execute \":set \$myvar1 \$pptpdeconn\";} else={\r\
    \n\t:set pptpdeconn \"disconnected\";\r\
    \n\t:execute \":set \$myvar1 \$pptpdeconn\";\r\
    \n\t:if ([/interface l2tp-client get \$l2tpinterface running]=true) do={\r\
    \n\t:log warning \"\$l2tpinterface is running perfectly\";\r\
    \n\t:set l2tpdeconn \"connected\";\r\
    \n\t:execute \":set \$myvar2 \$l2tpdeconn\";} else={\r\
    \n\t:set l2tpdeconn \"disconnected\";\r\
    \n\t:execute \":set \$myvar2 \$l2tpdeconn\";\r\
    \n\t:if ([/interface ovpn-client get \$ovpninterface running]=true) do={\r\
    \n\t:log warning \"\$ovpninterface is running perfectly\";\r\
    \n\t:set ovpndeconn \"connected\";\r\
    \n\t:execute \":set \$myvar3 \$ovpndeconn\";} else={\r\
    \n\t:set ovpndeconn \"disconnected\";\r\
    \n\t:execute \":set \$myvar3 \$ovpndeconn\";};};}\r\
    \n\t\r\
    \n#PPTP linkup\t\r\
    \n:if ((\$pptpdeconn = \"connected\") || (\$l2tpdeconn = \"connected\") ||\
    \_(\$ovpndeconn = \"connected\")) do={\r\
    \n\t:log warning \"Linkup with Mikrotik Cloud Host Router is working\";} e\
    lse={\r\
    \n\t:log warning \"Linkup with Mikrotik Cloud Host Router is NOT working\"\
    ;\r\
    \n\t:log warning \"Starting to debug\";\r\
    \n\t:if ((\$pptpdeconn != \"connected\") && (\$l2tpdeconn != \"connected\"\
    ) && (\$ovpndeconn != \"connected\")) do={\r\
    \n\t\t:log warning \"\$pptpinterface turned off for 30 seconds\";\r\
    \n\t\t:log warning \"\$l2tpinterface turned off for 30 seconds\";\r\
    \n\t\t:log warning \"\$ovpninterface turned off for 30 seconds\";\r\
    \n\t\t:interface pptp-client disable \$pptpinterface;\r\
    \n\t\t:interface l2tp-client disable \$l2tpinterface;\r\
    \n\t\t:interface ovpn-client disable \$ovpninterface;\r\
    \n\t\t:local setip [/interface pptp-client get [/interface pptp-client fin\
    d name=\"\$pptpinterface\"]   connect-to];\r\
    \n\t\t:if (\$pppServerDnsName = \$setip) do={\r\
    \n\t\t  :log warning (\"No PPP server IP address change necessary\");} els\
    e={\r\
    \n\t\t  /interface pptp-client set [/interface pptp-client find name=\"\$p\
    ptpinterface\"]   connect-to=\"\$pppServerDnsName\";\r\
    \n\t\t  /interface l2tp-client set [/interface l2tp-client find name=\"\$l\
    2tpinterface\"]   connect-to=\"\$pppServerDnsName\";\r\
    \n\t\t  /interface ovpn-client set [/interface ovpn-client find name=\"\$o\
    vpninterface\"]   connect-to=\"\$pppServerDnsName\";\r\
    \n\t\t  :log warning (\"PPP server dynamic IP address changed from \" . \"\
    \$setip\" . \" to \" . \"\$pppServerDnsName\" );\r\
    \n\t\t  :global pppserverip \$current;}\r\
    \n\t\t:local setid [/interface pptp-client get [/interface pptp-client fin\
    d name=\"\$pptpinterface\"]   user];\r\
    \n\t\t:if (\$id = \$setid) do={\r\
    \n\t\t  :log warning (\"No PPP server username change necessary\");} else=\
    {\r\
    \n\t\t  /interface pptp-client set [/interface pptp-client find name=\"\$p\
    ptpinterface\"]   user=\"\$id\";\r\
    \n\t\t  /interface l2tp-client set [/interface l2tp-client find name=\"\$l\
    2tpinterface\"]   user=\"\$id\";\r\
    \n\t\t  /interface ovpn-client set [/interface ovpn-client find name=\"\$o\
    vpninterface\"]   user=\"\$id\";\r\
    \n\t\t  :log warning (\"PPP server username changed from \" . \"\$setid\" \
    . \" to \" . \"\$id\" );}\r\
    \n\t\t:local setpass [/interface pptp-client get [/interface pptp-client f\
    ind name=\"\$pptpinterface\"]   password];\r\
    \n\t\t:if (\$pass = \$setpass) do={\r\
    \n\t\t  :log warning (\"No PPP server password change necessary\");} else=\
    {\r\
    \n\t\t  /interface pptp-client set [/interface pptp-client find name=\"\$p\
    ptpinterface\"]   password=\"\$pass\";\r\
    \n\t\t  /interface l2tp-client set [/interface l2tp-client find name=\"\$l\
    2tpinterface\"]   password=\"\$pass\";\r\
    \n\t\t  /interface ovpn-client set [/interface ovpn-client find name=\"\$o\
    vpninterface\"]   password=\"\$pass\";\r\
    \n\t\t  :log warning (\"PPP server password changed from \" . \"\$setpass\
    \" . \" to \" . \"\$pass\" );}\r\
    \n\t\t:delay 10;\r\
    \n\t\t:interface pptp-client enable \$pptpinterface;\r\
    \n\t\t:log warning \"\$pptpinterface turned on and checking for connectivi\
    ty\";\r\
    \n\t\t:delay 10;\r\
    \n\t\t:if ([/interface pptp-client get \$pptpinterface running]=true) do={\
    \r\
    \n\t\t:log warning \"\$pptpinterface is running perfectly\";\r\
    \n\t\t:set pptpdeconn \"connected\";\r\
    \n\t\t:execute \":set \$myvar1 \$pptpdeconn\";} else={\r\
    \n\t\t:log warning \"\$pptpinterface is NOT running\";\r\
    \n\t\t:log warning \"\$pptpinterface is turned OFF\";\r\
    \n\t\t:set pptpdeconn \"disconnected\";\r\
    \n\t\t:execute \":set \$myvar1 \$pptpdeconn\";\r\
    \n\t\t:interface pptp-client disable \$pptpinterface;};}\r\
    \n# L2TP linkup\r\
    \n\t:if ((\$pptpdeconn != \"connected\") && (\$l2tpdeconn != \"connected\"\
    ) && (\$ovpndeconn != \"connected\")) do={\r\
    \n\t\t:local setip [/interface l2tp-client get [/interface l2tp-client fin\
    d name=\"\$l2tpinterface\"]   connect-to];\r\
    \n\t\t:if (\$pppServerDnsName = \$setip) do={\r\
    \n\t\t  :log warning (\"No PPP server IP address change necessary\");} els\
    e={\r\
    \n\t\t  /interface pptp-client set [/interface pptp-client find name=\"\$p\
    ptpinterface\"]   connect-to=\"\$pppServerDnsName\";\r\
    \n\t\t  /interface l2tp-client set [/interface l2tp-client find name=\"\$l\
    2tpinterface\"]   connect-to=\"\$pppServerDnsName\";\r\
    \n\t\t  /interface ovpn-client set [/interface ovpn-client find name=\"\$o\
    vpninterface\"]   connect-to=\"\$pppServerDnsName\";\r\
    \n\t\t  :log warning (\"PPP server dynamic IP address changed from \" . \"\
    \$setip\" . \" to \" . \"\$pppServerDnsName\" );\r\
    \n\t\t  :global pppserverip \$current;}\r\
    \n\t\t:local setid [/interface pptp-client get [/interface pptp-client fin\
    d name=\"\$pptpinterface\"]   user];\r\
    \n\t\t:if (\$id = \$setid) do={\r\
    \n\t\t  :log warning (\"No PPP server username change necessary\");} else=\
    {\r\
    \n\t\t  /interface pptp-client set [/interface pptp-client find name=\"\$p\
    ptpinterface\"]   user=\"\$id\";\r\
    \n\t\t  /interface l2tp-client set [/interface l2tp-client find name=\"\$l\
    2tpinterface\"]   user=\"\$id\";\r\
    \n\t\t  /interface ovpn-client set [/interface ovpn-client find name=\"\$o\
    vpninterface\"]   user=\"\$id\";\r\
    \n\t\t  :log warning (\"PPP server username changed from \" . \"\$setid\" \
    . \" to \" . \"\$id\" );}\r\
    \n\t\t:local setpass [/interface pptp-client get [/interface pptp-client f\
    ind name=\"\$pptpinterface\"]   password];\r\
    \n\t\t:if (\$pass = \$setpass) do={\r\
    \n\t\t  :log warning (\"No PPP server password change necessary\");} else=\
    {\r\
    \n\t\t  /interface pptp-client set [/interface pptp-client find name=\"\$p\
    ptpinterface\"]   password=\"\$pass\";\r\
    \n\t\t  /interface l2tp-client set [/interface l2tp-client find name=\"\$l\
    2tpinterface\"]   password=\"\$pass\";\r\
    \n\t\t  /interface ovpn-client set [/interface ovpn-client find name=\"\$o\
    vpninterface\"]   password=\"\$pass\";\r\
    \n\t\t  :log warning (\"PPP server password changed from \" . \"\$setpass\
    \" . \" to \" . \"\$pass\" );}\r\
    \n\t\t:interface l2tp-client enable \$l2tpinterface;\r\
    \n\t\t:log warning \"\$l2tpinterface turned on and checking for connectivi\
    ty\";\r\
    \n\t\t:delay 10;\r\
    \n\t\t:if ([/interface l2tp-client get \$l2tpinterface running]=true) do={\
    \r\
    \n\t\t:log warning \"\$l2tpinterface is running perfectly\";\r\
    \n\t\t:set l2tpdeconn \"connected\";\r\
    \n\t\t:execute \":set \$myvar2 \$l2tpdeconn\";} else={\r\
    \n\t\t:log warning \"\$l2tpinterface is NOT running\";\r\
    \n\t\t:log warning \"\$l2tpinterface is turned OFF\";\r\
    \n\t\t:set l2tpdeconn \"disconnected\";\r\
    \n\t\t:execute \":set \$myvar2 \$l2tpdeconn\";\r\
    \n\t\t:interface l2tp-client disable \$l2tpinterface;};};\r\
    \n# OVPN linkup\r\
    \n\t:if ((\$pptpdeconn != \"connected\") && (\$l2tpdeconn != \"connected\"\
    ) && (\$ovpndeconn != \"connected\")) do={\r\
    \n\t\t:local setip [/interface ovpn-client get [/interface ovpn-client fin\
    d name=\"\$ovpninterface\"]   connect-to];\r\
    \n\t\t:if (\$pppServerDnsName = \$setip) do={\r\
    \n\t\t  :log warning (\"No PPP server IP address change necessary\");} els\
    e={\r\
    \n\t\t  /interface pptp-client set [/interface pptp-client find name=\"\$p\
    ptpinterface\"]   connect-to=\"\$pppServerDnsName\";\r\
    \n\t\t  /interface l2tp-client set [/interface l2tp-client find name=\"\$l\
    2tpinterface\"]   connect-to=\"\$pppServerDnsName\";\r\
    \n\t\t  /interface ovpn-client set [/interface ovpn-client find name=\"\$o\
    vpninterface\"]   connect-to=\"\$pppServerDnsName\";\r\
    \n\t\t  :log warning (\"PPP server dynamic IP address changed from \" . \"\
    \$setip\" . \" to \" . \"\$pppServerDnsName\" );\r\
    \n\t\t  :global pppserverip \$current;}\r\
    \n\t\t:local setid [/interface pptp-client get [/interface pptp-client fin\
    d name=\"\$pptpinterface\"]   user];\r\
    \n\t\t:if (\$id = \$setid) do={\r\
    \n\t\t  :log warning (\"No PPP server username change necessary\");} else=\
    {\r\
    \n\t\t  /interface pptp-client set [/interface pptp-client find name=\"\$p\
    ptpinterface\"]   user=\"\$id\";\r\
    \n\t\t  /interface l2tp-client set [/interface l2tp-client find name=\"\$l\
    2tpinterface\"]   user=\"\$id\";\r\
    \n\t\t  /interface ovpn-client set [/interface ovpn-client find name=\"\$o\
    vpninterface\"]   user=\"\$id\";\r\
    \n\t\t  :log warning (\"PPP server username changed from \" . \"\$setid\" \
    . \" to \" . \"\$id\" );}\r\
    \n\t\t:local setpass [/interface pptp-client get [/interface pptp-client f\
    ind name=\"\$pptpinterface\"]   password];\r\
    \n\t\t:if (\$pass = \$setpass) do={\r\
    \n\t\t  :log warning (\"No PPP server password change necessary\");} else=\
    {\r\
    \n\t\t  /interface pptp-client set [/interface pptp-client find name=\"\$p\
    ptpinterface\"]   password=\"\$pass\";\r\
    \n\t\t  /interface l2tp-client set [/interface l2tp-client find name=\"\$l\
    2tpinterface\"]   password=\"\$pass\";\r\
    \n\t\t  /interface ovpn-client set [/interface ovpn-client find name=\"\$o\
    vpninterface\"]   password=\"\$pass\";\r\
    \n\t\t  :log warning (\"PPP server password changed from \" . \"\$setpass\
    \" . \" to \" . \"\$pass\" );}\r\
    \n\t\t:interface ovpn-client enable \$ovpninterface;\r\
    \n\t\t:log warning \"\$ovpninterface turned on and checking for connectivi\
    ty\";\r\
    \n\t\t:delay 10;\r\
    \n\t\t:if ([/interface ovpn-client get \$ovpninterface running]=true) do={\
    \r\
    \n\t\t:log warning \"\$ovpninterface is running perfectly\";\r\
    \n\t\t:set ovpndeconn \"connected\";\r\
    \n\t\t:execute \":set \$myvar3 \$ovpndeconn\";} else={\r\
    \n\t\t:log warning \"\$ovpninterface is NOT running\";\r\
    \n\t\t:log warning \"\$ovpninterface is turned OFF\";\r\
    \n\t\t:set ovpndeconn \"disconnected\";\r\
    \n\t\t:execute \":set \$myvar3 \$ovpndeconn\";\r\
    \n\t\t:interface ovpn-client disable \$ovpninterface;};};\t\r\
    \n\t:if ((\$l2tpdeconn = \"connected\") || (\$pptpdeconn = \"connected\") \
    || (\$ovpndeconn = \"connected\")) do={\r\
    \n\t:log warning \"Linkup with Mikrotik Cloud Host Router is up\";};};"
add dont-require-permissions=no name=reboot owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "/system reboot"
add dont-require-permissions=no name=sync_time owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="i\
    f ([ping 8.8.8.8 count=5] > 4) do={\r\
    \n\t/system ntp client set enabled=no primary-ntp=216.239.35.8 secondary-n\
    tp=216.239.35.0 server-dns-names=\"time.google.com,time1.google.com,time2.\
    google.com,time3.google.com,time4.google.com\";\r\
    \n\t:delay 15s;\r\
    \n\t/system ntp client set enabled=yes primary-ntp=216.239.35.8 secondary-\
    ntp=216.239.35.0 server-dns-names=\"time.google.com,time1.google.com,time2\
    .google.com,time3.google.com,time4.google.com\";\r\
    \n\t/system scheduler set sync_time interval=00:00:00;\r\
    \n\t:log warning \"SNTP Client Synchronized Current TIme\";} else={/system\
    \_scheduler set sync_time interval=00:01:00;\r\
    \n\t:log warning \"SNTP Client FAILED To Synchronize Current TIme\";}"