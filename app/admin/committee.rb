ActiveAdmin.register Committee do
  permit_params :name, country_ids: [], character_ids: []

  show do
    attributes_table do
      row :id
      row :name
      row :characters do |comm|
        if comm.characters.any?
          comm.characters.each do |char|
            div do
              a char.name, href: admin_character_path(char)
            end
          end
        else
          nil
        end
      end
      row :countries do |comm|
        if comm.countries.any?
          comm.countries.each do |country|
            div do
              a country.name, href: admin_country_path(country)
            end
          end
        else
          nil
        end
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :countries, :as => :select, :input_html => { :multiple => true, 
                                                           class: 'chosen-select',
                                                           :'data-placeholder' => 'Select countries...',
                                                           :'data-click-handler' => 'onCountryClick'
                                                         }
      f.input :characters, :as => :select, :input_html => { :multiple => true, 
                                                            class: 'chosen-select',
                                                            :'data-placeholder' => 'Select characters...',
                                                            :'data-click-handler' => 'onCharacterClick'
                                                          }
    end
    f.actions
  end
end
