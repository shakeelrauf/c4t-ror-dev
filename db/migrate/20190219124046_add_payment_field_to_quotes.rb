class AddPaymentFieldToQuotes < ActiveRecord::Migration[5.2]
  def change
    add_column :quotes, :payment_method, :string
  end
end
