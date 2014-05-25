ActiveAdmin.register Payment do
  permit_params :name, :amount, :payment_method, :currency, :state
  belongs_to :delegation

  scope :all
  scope :approved, default: true

  form do |f|
    f.form_buffers.last << Arbre::Context.new({}, f.template) do
    end
    f.inputs do
      f.input :amount
      f.input :payment_method, label: 'Type (e.g. Check)'
      f.input :currency, label: 'Currency (usd or eur)'
      f.input :state, as: :select,
              collection: options_for_select(['created', 'approved', 'failed', 'canceled', 'expired'], f.object.state.presence || 'approved')
    end
    f.actions
  end

end