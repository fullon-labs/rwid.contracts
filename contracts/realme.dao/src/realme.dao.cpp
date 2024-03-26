#include <realme.dao/realme.dao.hpp>

#include <math.hpp>
#include <utils.hpp>
#include <realme.owner.hpp>

static constexpr eosio::name active_permission{"active"_n};
static constexpr symbol   APL_SYMBOL          = symbol(symbol_code("APL"), 4);
static constexpr eosio::name MT_BANK{"amax.token"_n};

#define ALLOT_APPLE(farm_contract, lease_id, to, quantity, memo) \
    {   aplink::farm::allot_action(farm_contract, { {_self, active_perm} }).send( \
            lease_id, to, quantity, memo );}

namespace amax {

using namespace std;

#define CHECKC(exp, code, msg) \
   { if (!(exp)) eosio::check(false, string("[[") + to_string((int)code) + string("]] ")  \
                                    + string("[[") + _self.to_string() + string("]] ") + msg); }


   inline int64_t get_precision(const symbol &s) {
      int64_t digit = s.precision();
      CHECK(digit >= 0 && digit <= 18, "precision digit " + std::to_string(digit) + " should be in range[0,18]");
      return calc_precision(digit);
   }

   void realme_dao::init( const uint8_t& recover_threshold_pct, 
                           const name realme_owner_contract) {
      require_auth( _self );
      _gstate.recover_threshold_pct       = recover_threshold_pct;
      _gstate.realme_owner_contract         = realme_owner_contract;
   }

   void realme_dao::newaccount(const name& auth_contract, const name& creator, const name& account,  const authority& active ) {
      // check(is_account(account), "account invalid: " + account.to_string());
      recover_auth_t recoverauth(account);
      CHECKC( !_dbc.get(recoverauth), err::RECORD_EXISTING, "realme account already created" )
      auto now           = current_time_point();

      auto auditconf = _audit_item(auth_contract);
      CHECKC( auditconf.account_actived, err::NO_AUTH , "No permission to create account :" + auth_contract.to_string());

      // bool required = _audit_item(auth_contract);
      recoverauth.account 		                              = account;
      recoverauth.auth_requirements[auth_contract]          = auditconf.check_required;
      recoverauth.recover_threshold                         = 1;
      recoverauth.created_at                                = now;
      recoverauth.updated_at                                = now;
      _dbc.set(recoverauth, _self);

      realme_owner::newaccount_action newaccount_act(_gstate.realme_owner_contract, { {get_self(), "active"_n} });
      newaccount_act.send( auth_contract, creator, account, active);  

   }

   void realme_dao::addauth( const name& account, const name& contract ) {
      CHECKC( has_auth(account) , err::NO_AUTH, "no auth for operate" )
      _audit_item(contract);

      auto register_auth_itr     = register_auth_t(contract);
      CHECKC( !_dbc.get(account.value, register_auth_itr),  err::RECORD_EXISTING, "register auth already existed. ");

      recover_auth_t recoverauth(account);
      if ( _dbc.get(recoverauth) ) {
         CHECKC(recoverauth.auth_requirements.count(contract) == 0, err::RECORD_EXISTING, "contract already existed") 
      }

      auto register_auth_new    = register_auth_t(contract);
      register_auth_new.created_at = current_time_point();
      _dbc.set(account.value, register_auth_new, false);
   }

   void realme_dao::delauth(const name& auth_contract, const name& account ){
      require_auth ( auth_contract ); 

      bool required         = _audit_item(auth_contract).check_required;

      recover_auth_t recoverauth(account);
      CHECKC( _dbc.get(recoverauth), err::RECORD_NOT_FOUND, "account not exist.")
      CHECKC(recoverauth.auth_requirements.count(auth_contract) != 0, err::RECORD_EXISTING, "contract not existed") 
      // CHECKC(recoverauth.auth_requirements.size() > 1, err::RECORD_EXISTING, "auth contract  count must be > 1") 

      recoverauth.auth_requirements.erase(auth_contract);

      auto count = recoverauth.auth_requirements.size();
      auto threshold = _get_threshold(count + 1, _gstate.recover_threshold_pct);
      if ( recoverauth.recover_threshold <  threshold) recoverauth.recover_threshold = threshold;
      if ( count == 1) recoverauth.recover_threshold = 1;
      if ( recoverauth.auth_requirements.size() == 0){
         _dbc.del(recoverauth);
      }else {

         _dbc.set(recoverauth);
      }
   }

   void realme_dao::checkauth( const name& auth_contract, const name& account ) {
      require_auth ( auth_contract ); 
      uint8_t score         = 0;
      bool required         = _audit_item(auth_contract).check_required;

      auto register_auth_itr     = register_auth_t(auth_contract);
      CHECKC( _dbc.get(account.value, register_auth_itr),  err::RECORD_NOT_FOUND, "register auth not exist. ");
      _dbc.del_scope(account.value, register_auth_itr);

      recover_auth_t recoverauth(account);
      
      if (_dbc.get(recoverauth)) {
         CHECKC( !recoverauth.auth_requirements.count(auth_contract), err::RECORD_EXISTING, "contract not found:" +auth_contract.to_string() )
         auto count = recoverauth.auth_requirements.size();
         auto threshold = _get_threshold(count + 1, _gstate.recover_threshold_pct);
         if( recoverauth.recover_threshold <  threshold) recoverauth.recover_threshold = threshold;
         recoverauth.auth_requirements[auth_contract]       = required;
         recoverauth.updated_at                             = current_time_point();
         _dbc.set( recoverauth, _self);
      } else {
         recoverauth.auth_requirements[auth_contract]          = required;
         recoverauth.recover_threshold                         = 1;
         recoverauth.created_at                                = current_time_point();
         recoverauth.updated_at                                = current_time_point();
         _dbc.set(recoverauth, _self);
      }
   }
   
   uint32_t realme_dao::_get_threshold(uint32_t count, uint32_t pct) {
      int64_t tmp = 10 * count * pct / 100;
      return (tmp + 9) / 10;
   }

   void realme_dao::updatepubkey(const name& auth_contract, const name& account, const public_key& publickey){

      require_auth(auth_contract);

      recover_auth_t::idx_t recoverauths(_self, _self.value);
      auto audit_ptr     = recoverauths.find(account.value);
      CHECKC( audit_ptr != recoverauths.end(), err::RECORD_NOT_FOUND,"account not exist. ");
      CHECKC(audit_ptr->auth_requirements.count(auth_contract) > 0 , err::NO_AUTH, "no auth for set score: " + account.to_string());

      _audit_item(auth_contract);

      recoverauths.modify( *audit_ptr, _self, [&]( auto& row ) {
         row.last_recovered_at  = current_time_point();
      });
      
      _update_auth(audit_ptr->account, publickey);
   }

   void realme_dao::addauditconf( const name& check_contract, const name& audit_type, const audit_conf_s& conf ) {
      CHECKC(has_auth(_self),  err::NO_AUTH, "no auth for operate"); 

      CHECKC( conf.status == ContractStatus::RUNNING || conf.status == ContractStatus::STOPPED, 
                     err::PARAM_ERROR, "contract status error " + conf.status.to_string() )

      CHECKC( conf.max_score > 0 , err::PARAM_ERROR, "score error ")

      CHECKC(is_account(check_contract), err::PARAM_ERROR,"check_contract invalid: " + check_contract.to_string());

      audit_conf_t::idx_t auditscores(_self, _self.value);
      auto auditscore_ptr     = auditscores.find(check_contract.value);
      if( auditscore_ptr != auditscores.end() ) {
         auditscores.modify(*auditscore_ptr, _self, [&]( auto& row ) {
            row.audit_type    = audit_type;
            row.charge        = conf.charge;
            if( conf.title.length() > 0 )       row.title         = conf.title;
            if( conf.desc.length() > 0 )        row.desc          = conf.desc;
            if( conf.url.length() > 0 )         row.url           = conf.url;
            if( conf.max_score > 0 )            row.max_score   = conf.max_score;
            row.check_required = conf.check_required;
            row.status        = conf.status;
            row.account_actived = conf.account_actived;
         });   
      } else {
         auditscores.emplace(_self, [&]( auto& row ) {
            row.contract      = check_contract;
            row.audit_type    = audit_type;
            row.charge        = conf.charge;
            row.title         = conf.title;
            row.desc          = conf.desc;
            row.url           = conf.url;
            row.max_score     = conf.max_score;
            row.check_required = conf.check_required;
            row.status        = conf.status;
            row.account_actived = conf.account_actived;
         });
      }
   }

   void realme_dao::delauditconf(  const name& contract_name ) {
      CHECKC(has_auth(_self),  err::NO_AUTH, "no auth for operate");      

      audit_conf_t::idx_t auditscores(_self, _self.value);
      auto auditscore_ptr     = auditscores.find(contract_name.value);

      CHECKC( auditscore_ptr != auditscores.end(), err::RECORD_NOT_FOUND, "auditscore not exist. ");
      auditscores.erase(auditscore_ptr);
   }

   const audit_conf_t& realme_dao::_audit_item(const name& contract) {
      audit_conf_t::idx_t auditscores(_self, _self.value);

      auto auditscore_ptr     = auditscores.find(contract.value);
      CHECKC( auditscore_ptr != auditscores.end(), err::RECORD_NOT_FOUND,  "audit_conf_t contract not exist:  " + contract.to_string());
      CHECKC( auditscore_ptr->status == ContractStatus::RUNNING, err::STATUS_ERROR,  "contract status is error: " + contract.to_string());
      return auditscores.get(contract.value);
      // return auditscore_ptr;
   }

   void realme_dao::_update_auth( const name& account, const eosio::public_key& pubkey ) {
      realme_owner::updateauth_action updateauth_act(_gstate.realme_owner_contract, { {get_self(), "active"_n} });
      updateauth_act.send( account, pubkey);   
   }

}//namespace amax