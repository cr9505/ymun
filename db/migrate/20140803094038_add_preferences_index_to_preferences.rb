class AddPreferencesIndexToPreferences < ActiveRecord::Migration
  def change
    add_index :preferences, [ :delegation_id, :country_id ], :unique => true
  end
end
