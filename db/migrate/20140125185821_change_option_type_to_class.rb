class ChangeOptionTypeToClass < ActiveRecord::Migration
  def change
    remove_column :options, :type
    add_column :options, :class, :string
  end
end
