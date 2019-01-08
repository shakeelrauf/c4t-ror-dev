class CreateUserConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :user_configs do |t|
      t.string :pw_reinit_key
      t.datetime :pw_reinit_exp
      t.integer :user_id, foreign_key: true

      t.timestamps
    end
    add_column :users, :force_new_pw, :boolean
    add_column :users, :salt, :string
  end
end
