class AddUsersFlatFeeToBusiness < ActiveRecord::Migration[5.2]
  def change
    add_column :business, :usersFlatFee, :boolean
  end
end
