module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups
    module Addons
      # Name of the component method
      def addon
        @addon ||= begin
          options[:addon].to_s.html_safe if options[:addon].present?
        end
      end

      # Used when the addon is optional
      def has_addon?
        addon.present?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::Addons)
