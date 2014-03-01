ActiveAdmin.register Committee do
  permit_params :name, country_ids: []
  
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

  form do |f|
    f.inputs do
      f.input :name

      f.input :countries, :as => :select, :input_html => { :multiple => true, class: 'chosen-select', :'data-placeholder' => 'Assign countries...' }
    end

    f.actions
  end
  
end
