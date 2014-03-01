class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.integer :country_id
      t.integer :delegation_id
      t.integer :order

      t.timestamps
    end
  end
end
