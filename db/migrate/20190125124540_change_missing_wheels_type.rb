class ChangeMissingWheelsType < ActiveRecord::Migration[5.2]
    def up
      change_column :QuotesCars, :missingWheels, :integer, default: 0
    end
    def down
      change_column :QuotesCars, :missingWheels, :boolean, default: 0
    end
end
