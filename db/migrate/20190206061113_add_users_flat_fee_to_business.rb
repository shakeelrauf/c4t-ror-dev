class AddUsersFlatFeeToBusiness < ActiveRecord::Migration[5.2]
  def change
    add_column :Business, :usersFlatFee, :boolean
  end
end
