#!/bin/bash
SERVICENAME="tomcat$1.service"

if([ -f /etc/systemd/system/$SERVICENAME ])
    then 
    if( systemctl -q is-active $SERVICENAME)
        then
        echo "Stopping $SERVICENAME..."
        sudo systemctl stop $SERVICENAME
    fi
    echo "Starting $SERVICENAME"
    sudo systemctl start $SERVICENAME
else
    echo "$SERVICENAME does not exist"
fi
