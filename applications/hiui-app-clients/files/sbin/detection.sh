#!/bin/sh

function online {
    if [ -e "/tmp/tertf/tertfinfo" ]; then
        result="/tmp/tertf/tertfinfo"
        awk '{print $1}' /etc/clients | while read line; do
            # local tmp=$(awk '$1==tolower("'$line'") {print $3,$4,$5,$6,$15}' $result)
            awk '$1==tolower("'$line'") {print $3,$4,$5,$6,$15}' $result | while read up down total_up total_down online; do
                if [ -n "$online" ]; then
                    res=$(awk '$1=="'$line'" {sub(/[0-1]/,"'$online'",$5);sub(/[0-9]+/,"'$up'",$8);sub(/[0-9]+/,"'$down'",$9);sub(/[0-9]+/,"'$total_up'",$10);sub(/[0-9]+/,"'$total_down'",$11);print}' /etc/clients)
                    sed -i "/$line/c $res" /etc/clients
                fi
            done
        done
    else
        arp-scan -I br-lan -l 2>/dev/null >/tmp/detection.log
        result="/tmp/detection.log"
        awk '{print $1}' /etc/clients | while read line; do
            local lower=$(echo $line | tr A-Z a-z)
            local tmp=$(grep $line $result)
            if [ -z "$tmp" ]; then
                res=$(awk '$1=="'$line'" {sub(/1/,"0",$5);print}' /etc/clients)
                sed -i "/$line/c $res" /etc/clients
            fi
        done
    fi
}

while true; do
    online
    sleep 10
done
