#include <rwid.auth/rwid.auth.hpp>

static constexpr eosio::name ACTIVE_PERM        = "active"_n;

namespace flon {
    using namespace std;

   #define CHECKC(exp, code, msg) \
      { if (!(exp)) eosio::check(false, string("[[") + to_string((int)code) + string("]] ")  \
                                    + string("[[") + _self.to_string() + string("]] ") + msg); }

   void flon_auth::init( const name& rwid_dao, const name& rwid_owner) {
      CHECKC(has_auth(_self),  err::NO_AUTH, "no auth for operate");

      _gstate.flon_dao_contract    = rwid_dao;
      _gstate.rwid_owner_contract      = rwid_owner;
   }

   void flon_auth::newaccount(const name& auth, const name& creator, const name& account, const string& info, const authority& active) {
      _check_action_auth(auth, ActionType::NEWACCOUNT);

      CHECKC( info.size() <= MAX_TITLE_SIZE && info.size() > 0 , err::PARAM_ERROR, "title size must be > 0 and <= " + to_string(MAX_TITLE_SIZE) );

      //check account in rwid.dao
      account_rwid_t accountrwid(account);
      CHECKC( !_dbc.get(accountrwid) , err::RECORD_EXISTING, "account info already exist. ");
      accountrwid.rwid_info  = info;
      accountrwid.created_at   = current_time_point();
      _dbc.set(accountrwid, _self);

      rwid_dao::newaccount_action newaccount_act(_gstate.flon_dao_contract, { {get_self(), ACTIVE_PERM} });
      newaccount_act.send(get_self(), creator, account, active);
   }

   void flon_auth::bindinfo ( const name& auth, const name& account, const string& info) {
      _check_action_auth(auth, ActionType::BINDINFO);
      CHECKC( info.size() <= MAX_TITLE_SIZE && info.size() > 0 , err::PARAM_ERROR, "title size must be > 0 and <= " + to_string(MAX_TITLE_SIZE) );
      CHECKC(is_account(account), err::PARAM_ERROR,  "account invalid: " + account.to_string());
      //check account in rwid.dao

      account_rwid_t accountrwid(account);
      CHECKC( !_dbc.get(accountrwid) , err::RECORD_EXISTING, "account info already exist.");
      accountrwid.rwid_info  = info;
      accountrwid.created_at   = current_time_point();
      _dbc.set(accountrwid, _self);

      rwid_dao::checkauth_action checkauth_act(_gstate.flon_dao_contract, { {get_self(), ACTIVE_PERM} });
      checkauth_act.send( get_self(),  account);
   }

   void flon_auth::updateinfo ( const name& auth, const name& account, const string& info) {

      _check_action_auth(auth, ActionType::UPDATEINFO);

      CHECKC( info.size() <= MAX_TITLE_SIZE && info.size() > 0 , err::PARAM_ERROR, "title size must be > 0 and <= " + to_string(MAX_TITLE_SIZE) );
      CHECKC( is_account(account), err::PARAM_ERROR,  "account invalid: " + account.to_string());

      account_rwid_t accountrwid(account);
      CHECKC( _dbc.get(accountrwid) , err::RECORD_NOT_FOUND, "account info not exist. ");

      accountrwid.rwid_info  = info;
      _dbc.set(accountrwid, _self);
   }

   void flon_auth::delinfo( const name& auth, const name& account){
      _check_action_auth(auth, ActionType::DELINFO);
      account_rwid_t accountrwid(account);
      CHECKC( _dbc.get(accountrwid) , err::RECORD_NOT_FOUND, "account info not exist. ");
      _dbc.del(accountrwid);

      rwid_dao::delauth_action delauth_act(_gstate.flon_dao_contract, { {get_self(), ACTIVE_PERM} });
      delauth_act.send( get_self(),  account);
   }

   void flon_auth::updatepubkey( const name& admin, const name& account, const public_key& pubkey){
      _check_action_auth(admin, ActionType::UPDATEPUBKEY);

      rwid_dao::updatepubkey_action updatepubkey_act(_gstate.flon_dao_contract, { {get_self(), ACTIVE_PERM} });
      updatepubkey_act.send(get_self(), account, pubkey);
   }

   void flon_auth::setauth( const name& auth, const set<name>& actions ) {
      require_auth(_self);      
      CHECKC(is_account(auth), err::PARAM_ERROR,  "account invalid: " + auth.to_string());

      auth_t::idx_t auths(_self, _self.value);
      auto auth_ptr = auths.find(auth.value);

      if( auth_ptr != auths.end() ) {
         auths.modify(*auth_ptr, _self, [&]( auto& row ) {
            row.actions      = actions;
         });   
      } else {
         auths.emplace(_self, [&]( auto& row ) {
            row.auth      = auth;
            row.actions      = actions;
         });
      }
   }

   void flon_auth::delauth(  const name& account ) {
      require_auth(_self);    

      auth_t::idx_t auths(_self, _self.value);
      auto auth_ptr     = auths.find(account.value);

      CHECKC( auth_ptr != auths.end(), err::RECORD_EXISTING, "auth not exist. ");
      auths.erase(auth_ptr);
   }

   void flon_auth::_check_action_auth(const name& auth, const name& action_type) {
      CHECKC(has_auth(auth),  err::NO_AUTH, "no auth for operate: " + auth.to_string());      

      auto auth_itr     = auth_t(auth);
      CHECKC( _dbc.get(auth_itr), err::RECORD_NOT_FOUND, "flon_auth auth not exist. ");
      CHECKC( auth_itr.actions.count(action_type), err::NO_AUTH, "flon_auth no action for " + auth.to_string());
   }

}
