ActiveAdmin.register User do
  permit_params :first_name, :last_name, :email, :type, :delegation_id, :to_be_invited, :inviter_id

  filter :email
  filter :created_at
  filter :delegation, collection: -> { Delegation.with_name }
  filter :type, as: :select

  controller do
    def scoped_collection
      resource_class.includes(:delegation)
    end
  end

  action_item :only => :show do
    link_to('Log in as User', become_admin_user_path(user))
  end

  action_item :only => :index do
    link_to('Export Advisor Data', export_admin_users_path(type: 'Advisor'))
  end

  action_item :only => :index do
    link_to('Export Delegate Data', export_admin_users_path(type: 'Delegate'))
  end

  member_action :become, :method => :get do
    user = User.find(params[:id])
    sign_in(:user, user)
    redirect_to root_url
  end

  member_action :confirm, :method => :get do
    user = User.find(params[:id])
    user.skip_confirmation!
    user.save
    redirect_to admin_user_path(user)
  end

  collection_action :export, :method => :get do
    users = User.where(type: params[:type]).order('delegation_id, type, last_name, first_name')
    csv = CSV.generate( encoding: 'Windows-1251' ) do |csv|
      # add headers
      csv << ["Delegation", "Type", "First Name", "Last Name", "Character/Country", "Committee", "Email"]
      # add data
      users.each do |user|
        row = []
        row << user.delegation.andand.name
        row << user.type
        row << user.first_name
        row << user.last_name
        row << if user.type == 'Delegate'
                  if user.seat
                    user.seat.name
                  end
                end
        row << if user.type == 'Delegate'
                  if user.seat
                    user.seat.committees.first.andand.name
                  end
                end
        row << user.email
        csv << row
      end      
    end
    # send file to user
    send_data csv.encode('Windows-1251'), type: 'text/csv; charset=windows-1251; header=present', disposition: "attachment; filename=export_#{params[:type].downcase}.csv"
  end

  index do
    selectable_column
    column :delegation, sortable: 'delegations.name' do |user|
      if user.delegation then link_to user.delegation.name, admin_delegation_path(user.delegation), :class => "delegation_link" else '-' end
    end
    column :type do |user|
      user.type.underscore.humanize
    end
    column :email
    column :first_name
    column :last_name
    actions do |user|
      if user.type == 'Advisor'
        link_to('Log in as', become_admin_user_path(user), class: 'member_link') + ' ' +
          if user.confirmed?
            'Already Confirmed'
          else
            link_to('Confirm Email', confirm_admin_user_path(user), class: 'member_link')
          end
      end
    end
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
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :type
      f.input :delegation
      if f.object.new_record?
        f.input :to_be_invited, as: :hidden, value: true
        f.input :inviter_id, as: :hidden, value: current_user.id
      end
    end
    f.actions
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
  
  csv do
    column :delegation do |user|
      user.delegation.andand.name
    end
    column :type
    column :first_name
    column :last_name
    column "Character/Country" do |user|
      if user.type == 'Delegate'
        if user.seat
          user.seat.name
        end
      end
    end
    column "Committee" do |user|
      if user.type == 'Delegate'
        if user.seat
          user.seat.committees.first.andand.name
        end
      end
    end
    column :email
  end

end
