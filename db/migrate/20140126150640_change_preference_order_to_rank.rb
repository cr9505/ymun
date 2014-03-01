class ChangePreferenceOrderToRank < ActiveRecord::Migration
  def change
    rename_column :preferences, :order, :rank
  end
end
