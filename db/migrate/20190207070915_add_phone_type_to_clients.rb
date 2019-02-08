class AddPhoneTypeToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :Clients, :phone_type, :string
  end
end
