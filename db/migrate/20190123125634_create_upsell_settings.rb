class CreateUpsellSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :upsell_settings do |t|
      t.integer :price_increase
      t.integer :deduction_money_figure
      t.integer :user_id, foreign_key: true
      t.timestamps
    end
  end
end
