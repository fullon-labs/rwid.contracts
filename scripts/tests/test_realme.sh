rd=nrealme.dao
ro=nrealme.owner
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
    . newaccount.sh $rd
    . newaccount.sh $ro
    . newaccount.sh $mblra
}

echo "----账号准备-----"
# create_account
echo "----账号准备完成-----"

echo "合约部署"
mset $rd realme.dao
mset $ro realme.owner
mset $mblra realme.auth

echo "合约部署完成"

echo "合约初始化"
mpush $ro init '["'$rd'","0.10000000 AMAX","0.10000000 AMAX"]' -p$ro
mpush $rd init '[70,"'$ro'"]' -p$rd
mpush $mblra init '["'$rd'","'$ro'"]' -p$mblra

echo "合约初始化完成"