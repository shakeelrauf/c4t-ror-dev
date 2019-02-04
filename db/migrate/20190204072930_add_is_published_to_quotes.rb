class AddIsPublishedToQuotes < ActiveRecord::Migration[5.2]
  def change
    add_column :Quotes, :is_published, :boolean, default: false
  end
end
