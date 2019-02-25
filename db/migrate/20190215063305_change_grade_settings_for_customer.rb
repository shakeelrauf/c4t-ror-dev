class ChangeGradeSettingsForCustomer < ActiveRecord::Migration[5.2]
  def up
    change_column :clients, :grade, :string, :null => true
    Customer.where(grade: "None").each do |customer|
      customer.grade = nil
      customer.save!
    end
  end

  def down
    change_column :clients, :grade, :string, :null => false
    Customer.where(grade: nil).each do |customer|
      customer.grade = "None"
      customer.save!
    end
  end
end
