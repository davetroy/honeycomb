class AddPeopleAttributes < ActiveRecord::Migration
  def self.up
    add_column :people, :twitter_username, :string, :limit => 40
    add_column :people, :present, :boolean
  end

  def self.down
    remove_column :people, :twitter_username
    remove_column :people, :present
  end
end
