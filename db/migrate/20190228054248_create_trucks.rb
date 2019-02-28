class CreateTrucks < ActiveRecord::Migration[5.2]
  def change
    create_table :trucks do |t|
      t.string :name
      t.string :make
      t.string :model
      t.integer :year
      t.boolean :flatbed
      t.integer :flatbed_type
      t.integer :car_capacity
      t.string :weight_capacity
      t.timestamps
    end
  end
end
