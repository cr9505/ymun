# http://stackoverflow.com/questions/14972253/simpleform-default-input-class
# https://github.com/plataformatec/simple_form/issues/316
 
inputs = %w[
  CollectionSelectInput
  DateTimeInput
  FileInput
  GroupedCollectionSelectInput
  NumericInput
  PasswordInput
  RangeInput
  StringInput
  TextInput
  CollectionInput
  PriorityInput
]
 
# Instead of creating top-level custom input classes like TextInput, we wrap it into a module and override
# mapping in SimpleForm::FormBuilder directly
#
SimpleFormBootstrapInputs = Module.new
inputs.each do |input_type|
  superclass = "SimpleForm::Inputs::#{input_type}".constantize

  new_class = SimpleFormBootstrapInputs.const_set(input_type, Class.new(superclass) do
    def input_html_classes
      super.push('form-control')
    end
  end)

  # Now override existing usages of superclass with new_class
  SimpleForm::FormBuilder.mappings.each do |(type, target_class)|
    if target_class == superclass
      SimpleForm::FormBuilder.map_type(type, to: new_class)
    end
  end
end
 
# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.boolean_style = :nested
  
  config.wrappers :bootstrap3, tag: 'div', class: 'form-group', error_class: 'has-error',
      defaults: { input_html: { class: 'default_class' } } do |b|
    
    b.use :html5
    
    b.use :min_max
    b.use :maxlength
    b.use :placeholder
    b.optional :pattern
    b.optional :readonly
    
    b.use :label_input
    b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    # b.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
  end
 
  config.wrappers :prepend, tag: 'div', class: "form-group", error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'controls' do |input|
      input.wrapper tag: 'div', class: 'input-prepend' do |prepend|
        prepend.use :input
      end
      input.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
      # input.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    end
  end
 
  config.wrappers :append, tag: 'div', class: "control-group", error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'controls' do |input|
      input.wrapper tag: 'div', class: 'input-append' do |append|
        append.use :input
      end
      input.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
      # input.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    end
  end

  config.wrappers :with_addons, :tag => 'div', :class => 'form-group', :error_class => 'error' do |b|
    b.use :html5
    b.use :label
    b.wrapper :tag => 'div', class: 'input-group' do |ba|
      ba.use :placeholder
      ba.use :addon, :wrap_with => { :tag => 'span', :class => 'input-group-addon'}
      ba.use :input
      # ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
      ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
    end
  end
 
  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://getbootstrap.com/)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap3
end