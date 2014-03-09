ActiveAdmin.register Payment do
  permit_params :name, :amount, :method, :currency, :state
  belongs_to :delegation

  form do |f|
    f.form_buffers.last << Arbre::Context.new({}, f.template) do
      input type: 'hidden', name: 'payment[state]', value: 'approved'
    end
    f.inputs do
      f.input :amount
      f.input :method, label: 'Type (e.g. Check)'
      f.input :currency, label: 'Currency (usd or eur)'
    end
    f.actions
  end

end