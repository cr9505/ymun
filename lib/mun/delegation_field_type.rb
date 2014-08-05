module Mun
  class DelegationFieldType
    include AbstractController::Rendering
    attr_accessor :class_name, :human_name, :description, :interface,
                  :validator, :form_partial, :admin_renderer, :valuer,
                  :input_type, :should_admin_render

    class << self
      def register_types(&block)
        self.instance_eval(&block)
      end

      def type(class_name, &block)
        delegation_field_type = self.new(class_name)
        dsl_interface = delegation_field_type.interface
        dsl_interface.instance_eval(&block)
        types[class_name] = delegation_field_type
      end

      def types
        if @types.nil?
          @types = {}
          # WART
          load "#{File.dirname(__FILE__)}/delegation_field_type/register.rb"
        end
        @types
      end

      def type_options
        types.collect do |class_name, delegation_field_type|
          [delegation_field_type.human_name || class_name, class_name]
        end
      end
    end

    class DslInterface
      def initialize(delegation_field_type)
        @delegation_field_type = delegation_field_type
      end

      def human_name(human_name)
        @delegation_field_type.human_name = human_name
      end

      def description(description = nil, &block)
        if block_given?
          @delegation_field_type.description = yield
        else
          @delegation_field_type.description = description
        end
      end

      def validate(&block)
        @delegation_field_type.validator = block
      end

      def form_partial(partial)
        @delegation_field_type.form_partial = partial
      end

      def admin_render(partial = nil, &block)
        if block_given?
          @delegation_field_type.admin_renderer = block
        elsif partial
          @delegation_field_type.admin_renderer = Proc.new do |delegation, delegation_field|
            render(partial: partial, locals: { delegation: delegation, delegation_field: delegation_field })
          end
        else
          @delegation_field_type.should_admin_render = false
        end
      end

      def value(&block)
        @delegation_field_type.valuer = block
      end

      def input_type(input_type)
        @delegation_field_type.input_type = input_type
      end
    end

    def initialize(class_name)
      @class_name = class_name
      @human_name ||= @class_name
      @should_admin_render = true
      @form_partial = 'delegation_field_types/base'
      @interface = DslInterface.new(self)
    end

    def admin_render(value_string, delegation)
      if admin_renderer
        instance_exec(value_string, delegation, &admin_renderer)
      else
        value(value_string)
      end
    end

    def validate(delegation_field_value, delegation)
      if validator
        instance_exec(delegation_field_value, delegation, &validator)
      else
        true
      end
    end

    def value(value_string, delegation)
      if valuer
        valuer.call(value_string)
      else
        value_string
      end
    end

    private

    def render(options = {})
      options = options.merge({ format: :html })
      ActionView::Base.new(Rails.configuration.paths['app/views']).render(options)
    end
  end
end
