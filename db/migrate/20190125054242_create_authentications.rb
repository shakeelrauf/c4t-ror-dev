class CreateAuthentications < ActiveRecord::Migration[5.2]
  def change
    create_table :authentications do |t|
      t.string :token
      t.integer :user_id

      t.timestamps
    end
  end
end
