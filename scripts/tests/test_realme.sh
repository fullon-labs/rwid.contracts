#!/bin/bash
amcli wallet unlock --password PW5JN2qJarqzKEQC6mSB79RWc5LdUS2don2SMfZ41efbu1oGveL45

rd=nrwid.dao
ro=nrwidowner
mblra=nmbl.auth

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
    . ./scripts/tests/newaccount.sh $rd
    . ./scripts/tests/newaccount.sh $ro
    . ./scripts/tests/newaccount.sh $mblra
}

echo "----账号准备-----"
create_account
echo "----账号准备完成-----"

echo "合约部署"
mset $rd rwid.dao
mset $ro rwid.owner
mset $mblra rwid.auth

echo "合约部署完成"

echo "合约初始化"
echo mpush $ro init '["'$rd'","0.10000000 flon","0.10000000 flon"]' -p$ro
mpush $rd init '[70,"'$ro'"]' -p$rd
mpush $mblra init '["'$rd'","'$ro'"]' -p$mblra

echo "合约初始化完成"

