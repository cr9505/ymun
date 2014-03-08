ActiveAdmin.register Option do
  permit_params :name, :value

  actions :all, except: [:destroy]

  show do |option|
    attributes_table do
      row :name
      row :slug
      row :value
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Option" do
      f.input :name
      case f.object.class_name
      when 'Text'
        f.input :value, as: :text
      when 'String'
        f.input :value
      when 'Integer'
        f.input :value
      when 'Date'
        f.input :value, as: :datepicker
      end
    end
    f.actions
  end

  index do
    column :name
    column :value
    column :updated_at
    actions
  end
  
  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end
  
end
