require 'redmine'
require 'casclient'
require 'casclient/frameworks/rails/filter'

module RedmineRubyCas
  extend self

  def plugin
    Redmine::Plugin.find(:redmine_rubycas)
  end

  def settings
    if self.plugin
      Setting.plugin_redmine_rubycas || plugin.settings[:default]
    end
  end

  def setting(name)
    settings && settings.has_key?(name) && settings[name] || nil
  end

  def enabled?
    setting("enabled") == "true"
  end

  def configure!
    if enabled?
      CASClient::Frameworks::Rails::Filter.configure(
        :cas_base_url => setting("base_url"),
        :login_url => setting("login_url").blank? ? nil : setting("login_url"),
        :logout_url => setting("logout_url").blank? ? nil : setting("logout_url"),
        :validate_url => setting("validate_url").blank? ? nil : setting("validate_url"),
        :username_session_key => setting("username_session_key"),
        :extra_attributes_session_key => setting("extra_attributes_session_key"),
        :logger => Rails.logger
      )
    end
  end

  def extra_attributes_map
    attrs = {}
    setting("auto_user_attributes_map").scan(/((\w+)=(\w+))&?/) do |match|
      redmineAttr = match[1]
      casAttr = match[2]
      attrs[casAttr] = redmineAttr
    end
    attrs
  end

  def user_extra_attributes_from_session(session)
    attrs = {}
    map = extra_attributes_map
    if extra_attributes = session[:"#{setting("extra_attributes_session_key")}"]
      extra_attributes.each_pair do |key, val|
        attrs[map[key]] = val
      end
    end
    attrs
  end
end
