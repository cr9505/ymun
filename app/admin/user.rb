ActiveAdmin.register User do
  filter :email
  filter :created_at
  filter :delegation

  index do
    selectable_column
    column :email
    column :type do |user|
      user.type.underscore.humanize
    end
    column :delegation do |user|
      if user.delegation then link_to user.delegation.name, admin_delegation_path(user.delegation), :class => "delegation_link" else '-' end
    end
    actions
  end

  show do |user|
    attributes_table do
      row :email
      row :type
      row :delegation
      row :created_at
      row :sign_in_count
    end
  end

  form do |f|
    f.inputs "User" do
      f.input :email
      f.input :type
      f.input :delegation
    end
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
