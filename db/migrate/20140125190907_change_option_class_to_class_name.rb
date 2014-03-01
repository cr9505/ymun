class ChangeOptionClassToClassName < ActiveRecord::Migration
  def change
    remove_column :options, :class
    add_column :options, :class_name, :string
  end
end
