#!/bin/bash

tcli(){ 
    amcli -u http://t1.nchain.me:18887 "$@"
}
mpush(){ 
    tcli push action "$@" 
}
mset(){
    tcli set contract $1 build/contracts/$2/ -p $1; 
}
amcli wallet unlock --password PW5JN2qJarqzKEQC6mSB79RWc5LdUS2don2SMfZ41efbu1oGveL45

name=$1
owner="ad"
creator="flon"
public_key="AM8HsW65MsXLy8jEpf9DBtkpGvu8NFfHFFNGiSKU7AuuLnb78DPe"

tcli system newaccount --stake-net "1.0000 flon" --stake-cpu "1.0000 flon" --buy-ram-kbytes 8000 $creator $name $public_key -p $creator
mpush flon updateauth '{"account": "'$name'", "permission": "owner", "parent": "", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight":1,"permission":{"actor":"ad","permission":"active"}}]}}' -p$name@owner
mpush flon updateauth '{"account": "'$name'", "permission": "active", "parent": "owner", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight":1,"permission":{"actor":"ad","permission":"active"}}]}}' -p$name@active

