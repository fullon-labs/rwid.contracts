#pragma once

#include <eosio/action.hpp>
#include <eosio/print.hpp>
#include <wasm_db.hpp>
#include <flon_system.hpp>
#include <eosio/asset.hpp>
using std::string;
using std::set;

namespace flon {

   typedef std::variant<eosio::public_key, string> recover_target_type;

   using eosio::checksum256;
   using eosio::ignore;
   using eosio::name;
   using eosio::asset;
   using eosio::permission_level;
   using eosio::public_key;
   using flon::authority;

class rwid_dao {
      public: 
      
            [[eosio::action]] 
            void newaccount( const name& auth_contract, const name& creator, const name& account, const authority& active );

            [[eosio::action]] 
            ACTION checkauth( const name& auth_contract, const name& account );

            [[eosio::action]] 
            ACTION setscore( const name& auth_contract, const name& account, const uint64_t& order_id, const uint64_t& score);
            ACTION delregauth(const name& auth_contract, const name& account );
            [[eosio::action]] 
            ACTION createorder(
                     const uint64_t&            sn,
                     const name&                auth_contract,
                     const name&                account,
                     const bool&                manual_check_required,
                     const uint64_t&            score,
                     const recover_target_type& recover_target);
            
            ACTION updatepubkey(const name& auth_contract, const name& account, const public_key& publickey);
            
            using newaccount_action       = eosio::action_wrapper<"newaccount"_n,   &rwid_dao::newaccount>;
            using checkauth_action        = eosio::action_wrapper<"checkauth"_n,    &rwid_dao::checkauth>;
            using setscore_action         = eosio::action_wrapper<"setscore"_n,     &rwid_dao::setscore>;
            using createcorder_action     = eosio::action_wrapper<"createorder"_n,  &rwid_dao::createorder>;
            using delregauth_action     = eosio::action_wrapper<"delregauth"_n,  &rwid_dao::delregauth>;
            using updatepubkey_action     = eosio::action_wrapper<"updatepubkey"_n,  &rwid_dao::updatepubkey>;
};

}