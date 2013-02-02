require 'redmine_rubycas'
require 'account_controller_patch'
require 'setting_model_patch'

Redmine::Plugin.register :redmine_rubycas do
  name 'Redmine RubyCAS plugin'
  author 'Brandon Aaron'
  description 'This is a plugin for Redmine 2+ that integrates the RubyCAS client.'
  version '0.0.1'
  url 'https://github.com/brandonaaron/redmine_rubycas'
  author_url 'http://brandonaaron.net/'

  requires_redmine :version_or_higher => '2.2.2'

  menu(:account_menu, :login_without_cas, { :controller => "account", :action => "login_without_cas" },
    :caption => :login_without_cas, :after => :login,
    :if => Proc.new { RedmineRubyCas.enabled? && RedmineRubyCas.setting("maintain_standard_login") == "true" && !User.current.logged? })

  settings(:partial => 'settings/redmine_rubycas_settings', :default => {
    # plugin settings
    :enabled => false,
    :maintain_standard_login => true,
    :auto_create_users => false,
    :auto_update_users => false,
    :auto_user_attributes_map => 'firstname=firstName&lastname=lastName&mail=mail',
    :logout_of_cas_on_logout => true,
    # cas client config settings
    :base_url => "https://cas.yourcasserver.com",
    :login_url => nil,
    :logout_url => nil,
    :validate_url => nil,
    :username_session_key => 'cas_user',
    :extra_attributes_session_key => 'cas_extra_attributes'
  })
end

RedmineRubyCas.configure!

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'account_controller'
  require_dependency 'setting'
  AccountController.send(:include, AccountControllerPatch)
  Setting.send(:include, SettingModelPatch)
end
