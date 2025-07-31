#pragma once

#include <eosio/asset.hpp>
#include <eosio/privileged.hpp>
#include <eosio/singleton.hpp>
#include <eosio/system.hpp>
#include <eosio/time.hpp>


#include <optional>
#include <string>
#include <map>
#include <set>
#include <type_traits>


namespace flon {

using namespace std;
using namespace eosio;
#define SYMBOL(sym_code, precision) symbol(symbol_code(sym_code), precision)

static constexpr eosio::name RECOVER_ACCOUNT    = "rwid.dao"_n;

static constexpr eosio::symbol SYS_SYMB         = SYMBOL("FLON", 8);
static constexpr eosio::name SYS_CONTRACT       = "flon"_n;
static constexpr eosio::name OWNER_PERM         = "owner"_n;
static constexpr eosio::name ACTIVE_PERM        = "active"_n;

#define TBL struct [[eosio::table, eosio::contract("rwid.owner")]]
#define NTBL(name) struct [[eosio::table(name), eosio::contract("rwid.owner")]]

NTBL("global") global_t {
    name        flon_dao_contract       = RECOVER_ACCOUNT;
    uint64_t    ram_bytes               = 5000;
    asset       gas_quant               = asset(300000, SYS_SYMB);
    EOSLIB_SERIALIZE( global_t, (flon_dao_contract)(ram_bytes)(gas_quant))
};
typedef eosio::singleton< "global"_n, global_t > global_singleton;

} //namespace flon