class CreateCountryCommittees < ActiveRecord::Migration
  def change
    create_table :country_committees do |t|
      t.references :country
      t.references :committee
    end
  end
end
