#!/bin/sh
ethn=$1

if [ "$(uci get wireguard.@proxy[0].enable)" = "1" ]; then
    RX_pre=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $2}')
    TX_pre=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $10}')
    if [ -z "$RX_pre" ]; then
        echo -e '{"up":"0 KB/s","down":"0 KB/s","interface":"'$ethn'","date":"'$(date +"%Y-%m-%d %H:%M:%S")'"}'
    else
        RX_next=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $2}')
        TX_next=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $10}')
        #   clear
        #   echo -e "\t RX `date +%k:%M:%S` TX"
        RX=$((${RX_next} - ${RX_pre}))
        TX=$((${TX_next} - ${TX_pre}))
        if [[ $RX -lt 1024 ]]; then
            RX="${RX}B/s"
        elif [[ $RX -gt 1048576 ]]; then
            RX=$(echo $RX | awk '{printf("%.2fMB/s",$1/1048576 )}')
        else
            RX=$(echo $RX | awk '{printf("%.2fKB/s",$1/1024 )}')
        fi
        if [[ $TX -lt 1024 ]]; then
            TX="${TX}B/s"
        elif [[ $TX -gt 1048576 ]]; then
            TX=$(echo $TX | awk '{printf("%.2fMB/s",$1/1048576 )}')
        else
            TX=$(echo $TX | awk '{printf("%.2fKB/s",$1/1024 )}')
        fi
        echo -e '{"up":"'$RX'","down":"'$TX'","interface":"'$ethn'","date":"'$(date +"%Y-%m-%d %H:%M:%S")'"}'
    fi
fi
