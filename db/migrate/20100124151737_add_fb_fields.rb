class AddFbFields < ActiveRecord::Migration
  def self.up
    add_column :facebook_users, :name, :string
    add_column :facebook_users, :pic_square, :string
  end

  def self.down
    remove_column :facebook_users, :name
    remove_column :facebook_users, :pic_square
  end
end
