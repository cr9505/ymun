class AddTypeToOptions < ActiveRecord::Migration
  def change
    add_column :options, :type, :string
  end
end
