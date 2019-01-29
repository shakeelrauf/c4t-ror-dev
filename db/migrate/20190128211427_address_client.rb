class AddressClient < ActiveRecord::Migration[5.2]
  def up
    change_column :Address, :idClient, :integer, null: true
  end
  def down
    change_column :Address, :idClient, :integer, null: false
  end
end
