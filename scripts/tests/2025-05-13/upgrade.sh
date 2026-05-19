#!/bin/bash
set -e
shopt -s expand_aliases
source ~/.bashrc

git clone git@github.com:fullon-labs/rwid.contracts.git
cd rwid.contracts
bash ./build.sh
mset rwid.owner rwid.owner
mset rwid.dao rwid.dao
mset mobile.rwid rwid.auth
mset email.rwid rwid.auth

mpush mobile.rwid setadminauth \
'["rwid.admin", ["newaccount","bindinfo","updateinfo","delinfo","updatepubkey","setactive","changepubkey","createorder","setscore"]]' \
-p mobile.rwid

mpush email.rwid setadminauth \
'["rwid.admin", ["newaccount","bindinfo","updateinfo","delinfo","updatepubkey","setactive","changepubkey","createorder","setscore"]]' \
-p email.rwid
