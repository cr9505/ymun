class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.string :name
      t.string :slug
      t.text :value

      t.timestamps
    end
  end
end
