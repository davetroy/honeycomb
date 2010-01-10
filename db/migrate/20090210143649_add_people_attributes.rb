class AddPeopleAttributes < ActiveRecord::Migration
  def self.up
    add_column :people, :twitter_username, :string, :limit => 20
    add_column :people, :twitter_token, :string, :limit => 50
    add_column :people, :twitter_secret, :string, :limit => 50
    add_column :people, :membership_plan, :integer
  end

  def self.down
    remove_column :people, :twitter_username
    remove_column :people, :foursquare_token
    remove_column :people, :foursquare_secret
    remove_column :people, :twitter_token
    remove_column :people, :twitter_secret
    remove_column :people, :membership_plan
  end
end
