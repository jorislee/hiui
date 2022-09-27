#!/bin/sh

function online {
    arp-scan -I br-lan -l 2>/dev/null >/tmp/detection.log
    local result="/tmp/detection.log"
    awk '{print $1}' /etc/clients | while read line; do
        if [ -z "$(grep $line $result)" ]; then
            local res=$(awk '$1=='$line' {sub(/0/,1,$5);print}' /etc/clients)
            sed -i "/$line/c $res" /etc/clients
        fi
    done
}

function traffic {

}
