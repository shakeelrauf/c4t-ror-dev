class AddPaymentFieldToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :QuotesCars, :payment_method, :string
    add_column :QuotesCars, :customer_email, :string
  end
end
