class RemovePaymentAndEmailFromQuotesCars < ActiveRecord::Migration[5.2]
  def change
  	remove_column :quote_cars, :payment_method, :string
    remove_column :quote_cars, :customer_email, :string
  end
end
