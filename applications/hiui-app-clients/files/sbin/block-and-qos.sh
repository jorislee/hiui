#!/bin/sh

function addBlockList() {
    local has=$(ipset list | grep block_device)
    if [ -z "$has" ]; then
        ipset create block_device hash:mac maxelem 10000
    fi
    [ -z "$(iptables -S FORWARD | grep block_device)" ] && iptables -I FORWARD -m set --match-set block_device src -j DROP
    awk '$7==1 {print $1}' /etc/clients | while read mac; do
        ipset add block_device $mac
    done

}

case $1 in
'addBlockList')
    addBlockList
    ;;
*) ;;
esac
