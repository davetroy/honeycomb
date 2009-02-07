class AddTimeInfoToAppearance < ActiveRecord::Migration
  def self.up
    add_column :appearances, :day_number, :integer
    add_column :appearances, :first_seen_at, :datetime
    add_column :appearances, :last_seen_at, :datetime
  end

  def self.down
    remove_column :appearances, :last_seen_at
    remove_column :appearances, :first_seen_at
    remove_column :appearances, :day_number
  end
end
