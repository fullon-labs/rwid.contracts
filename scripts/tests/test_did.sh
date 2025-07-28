#!/bin/bash
amcli wallet unlock --password PW5JN2qJarqzKEQC6mSB79RWc5LdUS2don2SMfZ41efbu1oGveL45

sd=starnestdid
sdn=sndid.ntoken
fec=ad

tcli(){ 
    amcli -u http://t1.nchain.me:18887 "$@"
}

mset(){
    tcli set contract $1 build/contracts/$2/ -p $1; 
}

mpush(){ 
    tcli push action "$@" 
}

create_account(){
    . ./scripts/tests/newaccount.sh $sd
    . ./scripts/tests/newaccount.sh $sdn
}

echo "----账号准备-----"
create_account
echo "----账号准备完成-----"

mset $sd flon.did
mset $sdn did.ntoken

create_did_ntoken(){
    mpush $sdn create '[ad,1000000,[1000001,0],"https://xdao.mypinata.cloud/ipfs/QmZab14Y7KbG12RqvUdtqeiSa1aJRqcDzU78cL1bTHDMxn",ad]' -pad
    mpush $sdn issue '[ad,[1000000,[1000001,0]],""]' -pad
}

create_did_ntoken

amcli set account permission $sdn active --add-code
amcli set account permission $sd active --add-code

mpush $sd init '[ad,"'$sdn'","'$fec'",0]' -p$sd
mpush $sd addvendor '["alibaba",ad,1,"0.0000 APL","0.10000000 flon",[1000001,0]]' -pad

# 添加转账权限
mpush $sdn setacctperms '[ad,ad,[1000001,0],1,1]' -pad
mpush $sdn setacctperms '[ad,"'$sd'",[1000001,0],1,1]' -pad

mpush $sdn transfer '[ad,"'$sd'",[[1000,[1000001,0]]],""]' -pad
mpush flon.token transfer '[testdiduser,"'$sd'","0.10000000 flon","ad:1:iiiii"]' -ptestdiduser 
mpush $sd setdidstatus '[2,"ok",""]' -pad