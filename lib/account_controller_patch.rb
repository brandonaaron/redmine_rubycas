module AccountControllerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :login, :cas
      alias_method_chain :logout, :cas
    end
  end

  module InstanceMethods
    def login_with_cas
      if params[:username].blank? && params[:password].blank? && RedmineRubyCas.enabled?
        if session[:user_id].blank? && CASClient::Frameworks::Rails::Filter.filter(self)
          user = User.find_or_initialize_by_login(session[:"#{RedmineRubyCas.setting("username_session_key")}"])
          if user.new_record?
            if RedmineRubyCas.setting("auto_create_users") == "true"
              user.attributes = RedmineRubyCas.user_extra_attributes_from_session(session)
              user.status = User::STATUS_REGISTERED

              register_automatically(user) do
                onthefly_creation_failed(user)
              end
            else
              flash[:error] = l(:cas_user_not_found, :user => session[:"#{RedmineRubyCas.setting("username_session_key")}"])
              redirect_to home_url
            end
          else
            if user.active?
              if RedmineRubyCas.setting("auto_update_users") == "true"
                user.update_attributes(RedmineRubyCas.user_extra_attributes_from_session(session))
              end
              successful_authentication(user)
            else
              account_pending
            end
          end
        end
      else
        login_without_cas
      end
    end

    def logout_with_cas
      if RedmineRubyCas.enabled? && RedmineRubyCas.setting("logout_of_cas_on_logout")
        CASClient::Frameworks::Rails::Filter.logout(self, home_url)
        logout_user
      else
        logout_without_cas
      end
    end
  end
end
