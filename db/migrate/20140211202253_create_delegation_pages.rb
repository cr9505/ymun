class CreateDelegationPages < ActiveRecord::Migration
  def change
    create_table :delegation_pages do |t|
      t.string :name
      t.integer :order
    end
  end
end
