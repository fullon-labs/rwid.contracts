#include <rwid.owner/rwid.owner.hpp>

namespace flon {
    using namespace std;

   #define CHECKC(exp, code, msg) \
      { if (!(exp)) eosio::check(false, string("[[") + to_string((int)code) + string("]] ")  \
                                    + string("[[") + _self.to_string() + string("]] ") + msg); }

   void rwid_owner::init( const name& rwid_dao, const asset& gas_quant ) {
      CHECKC(has_auth(_self),  err::NO_AUTH, "no auth for operate");      

      _gstate.flon_dao_contract     = rwid_dao;
      _gstate.gas_quant    = gas_quant;
   }

   void rwid_owner::newaccount( const name& auth_contract, const name& creator, const name& account, const authority& active) {
      require_auth(_gstate.flon_dao_contract);
      _validate_active_auth(active);

      auto perm = creator != get_self()? OWNER_PERM : ACTIVE_PERM;
      flon_system::newaccount_action  act(SYS_CONTRACT, { {creator, perm} }) ;
      authority owner_auth  = { 1, {}, {{{get_self(), ACTIVE_PERM}, 1}}, {} }; 
      act.send( creator, account, owner_auth, active);


      flon_system::buygas_action act2(SYS_CONTRACT, { {_self, ACTIVE_PERM} });
      act2.send( _self, account, _gstate.gas_quant);

   }

   void rwid_owner::setactive( const name& account, const authority& active ) {
      require_auth(_gstate.flon_dao_contract);
      _set_active(account, active);
   }

   void rwid_owner::updateauth( const name& account, const eosio::public_key& pubkey ) {
      require_auth(_gstate.flon_dao_contract);

      authority auth = { 1, {{pubkey, 1}}, {}, {} };
      _set_active(account, auth);
   }

   void rwid_owner::_set_active(const name& account, const authority& active) {
      _validate_active_auth(active);
      flon_system::updateauth_action act(SYS_CONTRACT, { {account, OWNER_PERM} });
      act.send( account, ACTIVE_PERM, OWNER_PERM, active);
   }

   void rwid_owner::_validate_active_auth(const authority& active) {
      CHECKC(active.threshold > 0, err::PARAM_ERROR, "active threshold must be positive");
      CHECKC(active.keys.size() > 0, err::PARAM_ERROR, "active keys must not be empty");
      CHECKC(active.keys.size() <= MAX_ACTIVE_KEYS, err::PARAM_ERROR, "too many active keys");
      CHECKC(active.accounts.size() == 0, err::PARAM_ERROR, "active accounts are not supported");
      CHECKC(active.waits.size() == 0, err::PARAM_ERROR, "active waits are not supported");

      uint32_t total_weight = 0;
      for (uint32_t i = 0; i < active.keys.size(); ++i) {
         CHECKC(active.keys[i].weight > 0, err::PARAM_ERROR, "active key weight must be positive");
         total_weight += active.keys[i].weight;
         for (uint32_t j = i + 1; j < active.keys.size(); ++j) {
            CHECKC(!(active.keys[i].key == active.keys[j].key), err::PARAM_ERROR, "duplicate active key");
         }
      }
      CHECKC(total_weight >= active.threshold, err::PARAM_ERROR, "active threshold exceeds total key weight");
   }

}
