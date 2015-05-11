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

  controller do
    def scoped_collection
      Delegation.with_name
    end
  end

  index do
    selectable_column
    column :name
    column :id
    column :address do |delegation|
      delegation.address.andand.to_html
    end
    column :delegation_size
    column :advisor_count
    column :would_you_like_to_participate_in_our_online_education_system
    actions do |delegation|
      link_to 'Payments', admin_delegation_payments_path(delegation.id)
    end
  end

  show do
    attributes_table do
      row :name

      row 'Assigned Countries' do
        delegation.countries.map(&:name).join(', ')
      end

      delegation.all_fields.each do |field|
        dft = field.delegation_field_type
        if dft.admin_renderer
          row field.name do
            dft.admin_render(field.value, delegation)
          end
        end
      end

      row 'Total Delegation Payment' do
        "#{(delegation.payment_currency || 'usd').upcase} #{delegation.total_payment_owed(delegation.payment_currency || 'usd')}"
      end

      row 'Total Amount Paid' do
        "#{(delegation.payment_currency || 'usd').upcase} #{delegation.total_payment_paid(delegation.payment_currency || 'usd')} (Using: #{delegation.payment_type.andand.capitalize || 'Unknown payment method'})"
      end

      row 'Remaining Balance' do |n|
        "#{(delegation.payment_currency || 'usd').upcase} #{delegation.payment_balance(delegation.payment_currency || 'usd')}"
      end

      row 'Delegates' do
        delegation.delegates.map do |delegate|
          "#{delegate.first_name} #{delegate.last_name}: #{delegate.email}"
        end.join("<br />").html_safe
      end

      a 'Add a Payment', href: new_admin_delegation_payment_path(delegation.id)
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
