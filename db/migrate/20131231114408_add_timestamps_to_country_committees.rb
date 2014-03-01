class AddTimestampsToCountryCommittees < ActiveRecord::Migration
  def change
    add_column(:country_committees, :created_at, :datetime)
    add_column(:country_committees, :updated_at, :datetime)

    add_column(:country_committees, :changer_id, :integer)

    add_index(:country_committees, :changer_id)
  end
end
