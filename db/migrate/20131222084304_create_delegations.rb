class CreateDelegations < ActiveRecord::Migration
  def change
    create_table :delegations do |t|
      t.string :name

      t.timestamps
    end
  end
end
