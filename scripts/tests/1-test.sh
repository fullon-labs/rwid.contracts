#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

con=rw.owner2
mreg flon $con flonian
mtran flon $con "500 FLON"
mset $con rwid.owner
mcli set account permission $con active --add-code


dao=rw.dao2
mreg flon $dao flonian
mtran flon $dao "500 FLON"
mset $dao rwid.dao
mcli set account permission $dao active --add-code

auth=rw.aumobile2
mreg flon $auth flonian
mtran flon $auth "500 FLON"
mset $auth rwid.auth
mcli set account permission $auth active --add-code


authemail=rw.auemail2
mreg flon $authemail flonian
mtran flon $authemail "500 FLON"
mset $authemail rwid.auth
mcli set account permission $authemail active --add-code


authtg=rw.autg2
mreg flon $authtg flonian
mtran flon $authtg "500 FLON"
mset $authtg rwid.auth
mcli set account permission $authtg active --add-code





# rwid.owner  合约初始化
mpush $con init '["'"${dao}"'", "1.00000000 FLON"]' -p $con
creator=flonian  # 创建者账号
acc=aliceaaa1112   # 目标新账号
🔑 Private Key: 5Kc3XmkgAEpM3mCcy5HY4kzRdgPxMysUA6TodYQN2URBEsgQn9T
🔓 Public  Key: FU5LDJBQ8nUEMkkKN3REvq22X4k5rsKNiAbBbYmJMNz9ydZNJbXk
pubkey=FU5LDJBQ8nUEMkkKN3REvq22X4k5rsKNiAbBbYmJMNz9ydZNJbXk



# -测试使用
 mpush $con newaccount \
'["'"$dao"'", "'"$con"'", "'"$acc"'", {"threshold":1,"keys":[{"key":"'"$pubkey"'", "weight":1}],"accounts":[],"waits":[]}]' \
-p $dao -p flonian@active 


newpubkey=FU5LDJBQ8nUEMkkKN3REvq22X4k5rsKNiAbBbYmJMNz9ydZNJbXk
 







# rwid.auth 合约初始化

mpush $auth init '["'"$dao"'", "'"$con"'","mobileno"]' -p $auth

mpush $auth setadminauth \
'["'"$auth"'", ["newaccount","bindinfo", "updateinfo", "delinfo", "updatepubkey","createorder"]]' \
-p $auth


# rwid.dao 合约初始化
mpush $dao init '[75, "'"$con"'"]' -p $dao

mpush $dao addauditconf \
'["'"${auth}"'", "mobileno", {
  "charge":"0.00000000 FLON",
  "title":"手机号认证",
  "desc":"实名审计",
  "url":"https://yourdomain/kyc",
  "max_score":100,
  "check_required":false,
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







mpush $dao addauditconf \
'["'"${authtg}"'", "mail", {
  "charge":"0.00000000 FLON",
  "title":"tg",
  "desc":"tg",
  "url":"https://yourdomain/kyc",
  "max_score":100,
  "check_required":true,
  "status":"running",
  "account_actived":true
}]' \
-p $dao


mpush $dao createorder '[202508011001,"'"${auth}"'","aliceaaa1115",true,1,["string", "13800138000"] ]'\
 -p $auth -p $dao





new_acc=aliceaaa1213


mpush $auth newaccount \
'["'"$auth"'", "'"$con"'", "'"$new_acc"'", "1331234567", {"threshold":1,"keys":[{"key":"'"$newpubkey"'", "weight":1}],"accounts":[],"waits":[]}]' \
-p $auth  
 



mpush $auth updateinfo \
'["'"$auth"'", "'"$new_acc"'", "13312345678"]' \
-p $auth



mpush $dao addregauth '["'"$new_acc"'", "'"$authemail"'"]' -p $new_acc  
mpush $dao addregauth '["'"$new_acc"'", "'"$authtg"'"]' -p $new_acc  


mpush $dao checkauth '["'"$authemail"'", "'"$new_acc"'"]' -p $authemail
mpush $dao checkauth '["'"$auth"'", "'"$new_acc"'"]' -p $auth
mpush $dao checkauth '["'"$authtg"'", "'"$new_acc"'"]' -p $authtg

mpush $auth createorder '[202508011001,"'"${auth}"'","aliceaaa1123",false,1,["public_key","FU5LDJBQ8nUEMkkKN3REvq22X4k5rsKNiAbBbYmJMNz9ydZNJbXk"] ]'\
 -p $auth

mpush $auth createorder '[202508011035,"'"${auth}"'","aliceaaa1211",false,80,["public_key","FU5LDJBQ8nUEMkkKN3REvq22X4k5rsKNiAbBbYmJMNz9ydZNJbXk"] ]'\
 -p $auth


 mpush $dao delregauth  '["'"$authemail"'", "'"$new_acc"'"]' -p $authemail
 mpush $dao delregauth  '["'"$auth"'", "'"$new_acc"'"]' -p $auth




#删除订单
 mpush $dao  delorder '["aliceaaa1153", 14]' -p aliceaaa1153






 mpush $dao setscore '["'"${auth}"'", "aliceaaa1153", 14, 1]' -p $auth




 #删除配置项
 mpush $dao delauditconf '["'"${auth}"'"]' -p $dao