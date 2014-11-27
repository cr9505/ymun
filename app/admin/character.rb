ActiveAdmin.register Character do
  permit_params :name, :delegation_id, :seat_count
  
  form do |f|
    f.inputs do
      f.input :name
      f.input :delegation
      f.input :seat_count
    end
    f.actions
  end
end
