#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

# mreg flon rwid flonian

con=rwid.owner
mreg flon $con flonian
mtran flonian $con "100 FLON"
mset $con rwid.owner
mcli set account permission $con active --add-code


dao=rwid.dao
mreg flon $dao flonian
mtran flonian $dao "100 FLON"
mset $dao rwid.dao
mcli set account permission $dao active --add-code

auth=mobile.rwid
mreg flon $auth flonian
mtran flonian $auth "100 FLON"
mset $auth rwid.auth
mcli set account permission $auth active --add-code


authemail=email.rwid
mreg flon $authemail flonian
mtran flonian $authemail "100 FLON"
mset $authemail rwid.auth
mcli set account permission $authemail active --add-code





# 合约初始化
mpush $con init '["'"${dao}"'", "1.00000000 FLON"]' -p $con


mpush $auth init '["'"$dao"'", "'"$con"'","mobileno"]' -p $auth

mpush $auth setadminauth \
'["'"$auth"'", ["newaccount","bindinfo", "updateinfo", "delinfo", "updatepubkey","createorder"]]' \
-p $auth

mpush $dao init '[75, "'"$con"'"]' -p $dao
#也需要配置
mpush $dao addauditconf \
'["'"${auth}"'", "mobileno", {
  "charge":"0.00000000 FLON",
  "title":"手机号认证",
  "desc":"实名审计",
  "url":"https://yourdomain/kyc",
  "max_score":100,
  "check_required":true,
  "status":"running",
  "account_actived":true
}]' \
-p $dao

mpush $dao addauditconf \
'["'"${authemail}"'", "mail", {
  "charge":"0.00000000 FLON",
  "title":"邮箱认证",
  "desc":"邮箱审计",
  "url":"https://yourdomain/kyc",
  "max_score":100,
  "check_required":true,
  "status":"running",
  "account_actived":true
}]' \
-p $dao

