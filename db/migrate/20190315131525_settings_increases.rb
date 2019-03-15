class SettingsIncreases < ActiveRecord::Migration[5.2]
  def change
    Setting.create(:name=>"max_purchaser_increase", :label=>"max_purchaser_increase", :value=>20.0)
    Setting.create(:name=>"max_increase_with_admin_approval", :label=>"max_increase_with_admin_approval", :value=>40.0)
  end
end
