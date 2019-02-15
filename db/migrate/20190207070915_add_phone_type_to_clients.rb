class AddPhoneTypeToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :phone_type, :string
  end
end
