#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

# mreg flon rwid flonian

con_owner=rwid.owner
mreg flon $con_owner flonian
mtran flonian $con_owner "100 FLON"
mset $con_owner rwid.owner
mcli set account permission $con_owner active --add-code


con_dao=rwid.dao
mreg flon $con_dao flonian
mtran flonian $con_dao "100 FLON"
mset $con_dao rwid.dao
mcli set account permission $con_dao active --add-code

con_mobileauth=mobile.rwid
mreg flon $con_mobileauth flonian
mtran flonian $con_mobileauth "100 FLON"
mset $con_mobileauth rwid.auth
mcli set account permission $con_mobileauth active --add-code


con_emailauth=email.rwid
mreg flon $con_emailauth flonian
mtran flonian $con_emailauth "100 FLON"
mset $con_emailauth rwid.auth
mcli set account permission $con_emailauth active --add-code



#rwid.admin 的共钥： 
mreg flon rwid.admin 共钥(替换)   #私钥加密后给terr
# 合约初始化
mpush $con_owner init '["'"${con_dao}"'", "0.10000000 FLON"]' -p $con_owner # set gas as 0.1 FLON


rwid_admin=rwid.admin
mpush $con_mobileauth init '["'"$con_dao"'", "'"$con_owner"'","mobileno"]' -p $con_mobileauth

mpush $con_mobileauth setadminauth \
'["'"$rwid_admin"'", ["newaccount","bindinfo", "updateinfo", "delinfo", "updatepubkey","createorder"]]' \
-p $con_mobileauth


mpush $con_emailauth init '["'"$con_dao"'", "'"$con_owner"'","email"]' -p $con_emailauth

mpush $con_emailauth setadminauth \
'["'"$rwid_admin"'", ["newaccount","bindinfo", "updateinfo", "delinfo", "updatepubkey","createorder"]]' \
-p $con_emailauth

mpush $con_dao init '[75, "'"$con_owner"'"]' -p $con_dao # 75%
#也需要配置
mpush $con_dao addauditconf \
'["'"${con_mobileauth}"'", "mobileno", {
  "charge":"0.00000000 FLON",
  "title":"Mobile phone verification",
  "desc":"Mobile phone verification for account ownership",
  "url":"",
  "max_score":100,
  "check_required":true,
  "primary":true,
  "status":"running"
}]' \
-p $con_dao

mpush $con_dao addauditconf \
'["'"${con_emailauth}"'", "mail", {
  "charge":"0.00000000 FLON",
  "title":"Email verification",
  "desc":"Email verification for account ownership",
  "url":"",
  "max_score":100,
  "check_required":true,
  "primary":true,
  "status":"running"
}]' \
-p $con_dao

