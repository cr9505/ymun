ActiveAdmin.register Character do
  permit_params :name, :delegation_id, :seat_count, committee_ids: []

  show do
    attributes_table do
      row :id
      row :name
      row :delegation
      row :committees do |char|
        char.committees.each do |comm|
          div do
            a comm.name, href: admin_committee_path(comm)
          end
        end
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :delegation, :as => :select, :input_html => { class: 'chosen-select' }
      f.input :committees, :as => :select, :input_html => { :multiple => true, 
                                                            class: 'chosen-select',
                                                            :'data-placeholder' => 'Select committees...',
                                                            :'data-click-handler' => 'onCommitteeClick'
                                                          }
    end
    f.actions
  end
end
