module SettingModelPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      after_save :reconfigure_plugin_redmine_rubycas
    end
  end

  module InstanceMethods
    def reconfigure_plugin_redmine_rubycas
      if name == 'plugin_redmine_rubycas'
        RedmineRubyCas.configure!
      end
    end
  end
end
