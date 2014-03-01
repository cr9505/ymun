ActiveAdmin.register Delegation do
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

  index do
    selectable_column
    column :name
    column :address do |delegation|
      delegation.address.to_html
    end
    actions
  end

  show do
    attributes_table do
      row :name

      row 'Address' do |n|
        delegation.address.to_html
      end

      row 'Assigned Countries' do
        delegation.countries.map(&:name).join(', ')
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :countries, :as => :select, :input_html => { :multiple => true, 
                                                           class: 'chosen-select',
                                                           :'data-placeholder' => 'Assign countries...',
                                                           :'data-click-handler' => 'onCountryClick'
                                                         }
    end
    f.actions
  end
  
end
