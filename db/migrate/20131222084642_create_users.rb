class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :type

      t.references :delegation

      t.timestamps
    end
  end
end
