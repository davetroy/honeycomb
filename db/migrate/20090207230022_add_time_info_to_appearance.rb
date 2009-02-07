class AddTimeInfoToAppearance < ActiveRecord::Migration
  def self.up
    add_column :appearances, :day_number, :integer
    add_column :appearances, :first_seen_at, :datetime
    add_column :appearances, :last_seen_at, :datetime
    remove_column :appearances, :created_at
    remove_column :appearances, :updated_at
    add_index :appearances, :day_number
  end

  def self.down
    remove_column :appearances, :last_seen_at
    remove_column :appearances, :first_seen_at
    remove_column :appearances, :day_number
  end
end
