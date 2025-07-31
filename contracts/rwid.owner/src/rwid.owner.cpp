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

      auto perm = creator != get_self()? OWNER_PERM : ACTIVE_PERM;
      flon_system::newaccount_action  act(SYS_CONTRACT, { {creator, perm} }) ;
      authority owner_auth  = { 1, {}, {{{get_self(), ACTIVE_PERM}, 1}}, {} }; 
      act.send( creator, account, owner_auth, active);


      flon_system::buygas_action act2(SYS_CONTRACT, { {_self, ACTIVE_PERM} });
      act2.send( _self, account, _gstate.gas_quant);

   }

   void rwid_owner::updateauth( const name& account, const eosio::public_key& pubkey ) {
      require_auth(_gstate.flon_dao_contract);

      authority auth = { 1, {{pubkey, 1}}, {}, {} };
      flon_system::updateauth_action act(SYS_CONTRACT, { {account, OWNER_PERM} });
      act.send( account, ACTIVE_PERM, OWNER_PERM, auth);
   }

}
