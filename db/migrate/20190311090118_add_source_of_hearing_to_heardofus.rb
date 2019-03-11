class AddSourceOfHearingToHeardofus < ActiveRecord::Migration[5.2]
  def change
    add_column :heardsofus, :source, :string
  end
end
