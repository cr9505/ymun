class AddSaveButtonToPages < ActiveRecord::Migration
  def change
    add_column :delegation_pages, :save_button, :string
  end
end
