ActiveAdmin.register DelegationPage do
  permit_params :name, :step, delegation_fields_attributes: [:name, :class_name, :id, :_destroy]

  sortable sorting_attribute: :step_index
  
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

  show do |page|
    attributes_table do
      row :name

      row 'Fields' do |n|
        page.delegation_fields.map(&:name).join(', ')
      end

      a 'Edit Fields', href: admin_delegation_page_delegation_fields_path(page.id)
    end
  end

  index as: :sortable do
    label do |item|
      "#{item.step}: #{item.name}"
    end
    actions do |page|
      link_to 'Edit Fields', admin_delegation_page_delegation_fields_path(page.id)
    end
  end

  form do |f|
    f.inputs do
      f.input :name, required: true
      
      if f.object.id
        f.form_buffers.last << Arbre::Context.new({}, f.template) do
          li do
            a 'Edit Fields', href: admin_delegation_page_delegation_fields_path(f.object.id)
          end
        end
      end
    end
    f.actions
  end
  
end
