#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

con_owner=rwid.owner
mreg flon $con_owner flonian
mtran flon $con_owner "100 FLON"
mset $con_owner rwid.owner
mcli set account permission $con_owner active --add-code


con_dao=rwid.dao
mreg flon $con_dao flonian
mtran flon $con_dao "100 FLON"
mset $con_dao rwid.dao
mcli set account permission $con_dao active --add-code

con_mobileauth=mobile.rwid
mreg flon $con_mobileauth flonian
mtran flon $con_mobileauth "100 FLON"
mset $con_mobileauth rwid.auth
mcli set account permission $con_mobileauth active --add-code


con_emailauth=email.rwid
mreg flon $con_emailauth flonian
mtran flon $con_emailauth "100 FLON"
mset $con_emailauth rwid.auth
mcli set account permission $con_emailauth active --add-code


con_authtg=tg.rwid
mreg flon $con_authtg flonian
mtran flon $con_authtg "100 FLON"
mset $con_authtg rwid.auth
mcli set account permission $con_authtg active --add-code





# rwid.owner  合约初始化
mpush $con_owner init '["'"${con_dao}"'", "0.10000000 FLON"]' -p $con_owner
creator=flonian  # 创建者账号
acc=aliceaaa1112   # 目标新账号
🔑 Private Key: 5Kc3XmkgAEpM3mCcy5HY4kzRdgPxMysUA6TodYQN2URBEsgQn9T
🔓 Public  Key: FU5LDJBQ8nUEMkkKN3REvq22X4k5rsKNiAbBbYmJMNz9ydZNJbXk
pubkey=FU5LDJBQ8nUEMkkKN3REvq22X4k5rsKNiAbBbYmJMNz9ydZNJbXk



# -测试使用
 mpush $con_owner newaccount \
'["'"$con_dao"'", "'"$con_owner"'", "'"$acc"'", {"threshold":1,"keys":[{"key":"'"$pubkey"'", "weight":1}],"accounts":[],"waits":[]}]' \
-p $con_dao -p flonian@active 


newpubkey=FU5LDJBQ8nUEMkkKN3REvq22X4k5rsKNiAbBbYmJMNz9ydZNJbXk
 







# rwid.auth 合约初始化

mpush $con_mobileauth init '["'"$con_dao"'", "'"$con_owner"'","mobileno"]' -p $con_mobileauth


rwid_admin=rwid.admin
mpush $con_mobileauth setadminauth \
'["'"$rwid_admin"'", ["newaccount","bindinfo", "updateinfo", "delinfo", "updatepubkey","createorder"]]' \
-p $con_mobileauth


mpush $con_emailauth init '["'"$con_dao"'", "'"$con_owner"'","email"]' -p $con_emailauth


rwid_admin=rwid.admin
mpush $con_emailauth setadminauth \
'["'"$rwid_admin"'", ["newaccount","bindinfo", "updateinfo", "delinfo", "updatepubkey","createorder"]]' \
-p $con_emailauth



# rwid.dao 合约初始化
mpush $con_dao init '[75, "'"$con_owner"'"]' -p $con_dao

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







mpush $con_dao addauditconf \
'["'"${con_authtg}"'", "mail", {
  "charge":"0.00000000 FLON",
  "title":"tg",
  "desc":"tg",
  "url":"https://yourdomain/kyc",
  "max_score":100,
  "check_required":true,
  "status":"running",
  "primary":true 
}]' \
-p $con_dao


mpush $con_dao createorder '[202508011001,"'"${con_mobileauth}"'","hufg2tdogcun",true,1,["string", "13800138000"] ]'\
 -p $con_mobileauth -p $con_dao





new_acc=aliceaaa1242


mpush $con_mobileauth newaccount \
'["'"$con_mobileauth"'", "'"$con_owner"'", "'"$new_acc"'", "1331234567", {"threshold":1,"keys":[{"key":"'"$newpubkey"'", "weight":1}],"accounts":[],"waits":[]}]' \
-p $con_mobileauth  
 



mpush $con_mobileauth updateinfo \
'["'"$con_mobileauth"'", "'"$new_acc"'", "13312345678"]' \
-p $con_mobileauth



mpush $con_dao addregauth '["'"$new_acc"'", "'"$con_emailauth"'"]' -p $new_acc  
mpush $con_dao addregauth '["'"$new_acc"'", "'"$con_authtg"'"]' -p $new_acc  


mpush $con_dao checkauth '["'"$con_emailauth"'", "'"$new_acc"'"]' -p $con_emailauth
mpush $con_dao checkauth '["'"$auth"'", "'"$new_acc"'"]' -p $auth
mpush $con_dao checkauth '["'"$con_authtg"'", "'"$new_acc"'"]' -p $con_authtg

mpush $con_mobileauth createorder '[202508011001,"'"${con_mobileauth}"'","aliceaaa1123",false,1,["public_key","FU5LDJBQ8nUEMkkKN3REvq22X4k5rsKNiAbBbYmJMNz9ydZNJbXk"] ]'\
 -p $con_mobileauth

mpush $con_mobileauth createorder '[42,"'"${con_mobileauth}"'","hufs4fo5meet",false,70,["public_key","FU5RCEwjWijBYchYag8kaz2ntGH3UEuEwL3fuApgwTSwGJ2Gij1s"] ]'\
 -p $con_mobileauth


 mpush $con_dao delregauth  '["'"$con_emailauth"'", "'"$new_acc"'"]' -p $con_emailauth
 mpush $con_dao delregauth  '["'"$con_mobileauth"'", "'"$new_acc"'"]' -p $con_mobileauth




#删除订单
 mpush $con_dao  delorder '["hufbkudowbby", 20]' -p aliceaaa1153






 mpush $con_dao setscore '["'"${con_mobileauth}"'", "aliceaaa1153", 14, 1]' -p $con_mobileauth




 #删除配置项
 mpush $con_dao delauditconf '["'"${con_emailauth}"'"]' -p $con_dao



  mpush $con_dao delrecauth '["hufzt1eiqwn2"]' -p $con_dao