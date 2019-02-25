class TableNames2 < ActiveRecord::Migration[5.2]
  def change
    rename_table :Clients, :clients2
    rename_table :clients2, :clients
  end
end
