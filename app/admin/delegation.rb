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
    actions do |delegation|
      link_to 'Payments', admin_delegation_payments_path(delegation.id)
    end
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

      delegation.all_fields.each do |field|
        case field.delegation_field.class_name
        when 'Title'
        when 'Name'
        when 'Address'
        when 'CommitteeTypeSelection'
          delegation.committee_type_selections.each do |cts|
            row cts.committee_type.name do |n|
              cts.delegate_count
            end
          end
        when 'Advisors'
          row 'Advisors' do |n|
            delegation.advisors.map{|a| "#{a.first_name} #{a.last_name}: #{a.email}"}.join('<br>').html_safe
          end
        when 'Preferences'
          row 'Preferences' do |n|
            delegation.preferences.map{|p| "#{p.rank}: #{p.country.andand.name || 'None'}"}.join('<br>').html_safe
          end
        when 'DelegationSize'
          row 'Delegation Size' do |n|
            delegation.delegation_size
          end
        else
          row field.delegation_field.name do |n|
            field.to_value
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
