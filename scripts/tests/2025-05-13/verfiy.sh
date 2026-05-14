#!/bin/bash
set -e
shopt -s expand_aliases
source ~/.bashrc

acc=aliceaaa1243
key1=FU5LDJBQ8nUEMkkKN3REvq22X4k5rsKNiAbBbYmJMNz9ydZNJbXk
key2=FU5RCEwjWijBYchYag8kaz2ntGH3UEuEwL3fuApgwTSwGJ2Gij1s
key3=FU6Dm6xR3JxpeEhdswTV4qTawYXjBcV4gtWjRPELaS9wbQzNmSUC
sn=$(date +%s)
sn1="${sn}01"
sn2="${sn}02"

./scripts/tests/2025-05-13/upgrade.sh

echo "0. create account, skip if already exists"
mpush mobile.rwid newaccount \
'["rwid.admin","rwid.owner","'"$acc"'","1331234567",{"threshold":1,"keys":[{"key":"'"$key1"'","weight":1}],"accounts":[],"waits":[]}]' \
-p rwid.admin || true

mcli get table rwid.dao rwid.dao recauths
mcli get account "$acc"

echo "1. old action: updatepubkey"
mpush mobile.rwid updatepubkey \
'["rwid.admin","'"$acc"'","'"$key1"'"]' \
-p rwid.admin

mcli get table rwid.dao rwid.dao activeauths
mcli get account "$acc"

echo "2. recovery: createorder to add pubkey"
mpush mobile.rwid createorder \
'['"$sn1"',"rwid.admin","'"$acc"'",false,0,["public_key","'"$key2"'"]]' \
-p rwid.admin

mcli get table rwid.dao rwid.dao recorders

order1=$(mcli get table --index snidx --key-type i64 -L "$sn1" -U "$sn1" --limit 1 rwid.dao rwid.dao recorders | sed -n 's/.*"id": \([0-9]*\).*/\1/p' | head -n 1)

echo "2.1 recovery: setscore to finish order"
mpush mobile.rwid setscore \
'["rwid.admin","'"$acc"'",'"$order1"',1]' \
-p rwid.admin

mcli get table rwid.dao rwid.dao activeauths
mcli get account "$acc"

echo "3. replace pubkey: changepubkey"
mpush mobile.rwid changepubkey \
'["rwid.admin","'"$acc"'","'"$key2"'","'"$key3"'"]' \
-p rwid.admin

echo "4. recovery: createorder to add another pubkey before batch delete"
mpush mobile.rwid createorder \
'['"$sn2"',"rwid.admin","'"$acc"'",false,0,["public_key","'"$key2"'"]]' \
-p rwid.admin

mcli get table rwid.dao rwid.dao recorders

order2=$(mcli get table --index snidx --key-type i64 -L "$sn2" -U "$sn2" --limit 1 rwid.dao rwid.dao recorders | sed -n 's/.*"id": \([0-9]*\).*/\1/p' | head -n 1)

echo "4.1 recovery: setscore to finish order"
mpush mobile.rwid setscore \
'["rwid.admin","'"$acc"'",'"$order2"',1]' \
-p rwid.admin

mcli get table rwid.dao rwid.dao activeauths
mcli get account "$acc"

echo "5. delete pubkeys: delpubkeys"
mpush mobile.rwid delpubkeys \
'["rwid.admin","'"$acc"'",["'"$key2"'","'"$key3"'"]]' \
-p rwid.admin

mcli get table rwid.dao rwid.dao activeauths
mcli get account "$acc"
