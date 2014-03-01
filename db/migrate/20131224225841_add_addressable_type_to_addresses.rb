class AddAddressableTypeToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :addressable_type, :string
  end
end
