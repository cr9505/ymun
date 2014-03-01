class CreateDelegationFields < ActiveRecord::Migration
  def change
    create_table :delegation_fields do |t|
      t.string :name
      t.string :slug
      t.string :class_name
      t.references :delegation_page
    end
  end
end
