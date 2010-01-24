class AddFoursquareFields < ActiveRecord::Migration
  def self.up
    add_column :foursquare_users, :firstname, :string
    add_column :foursquare_users, :lastname, :string
    add_column :foursquare_users, :photo, :string
  end

  def self.down
    remove_column :foursquare_users, :firstname
    remove_column :foursquare_users, :lastname
    remove_column :foursquare_users, :photo
  end
end
