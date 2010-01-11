class AddFoursquareUsers < ActiveRecord::Migration
  def self.up
    create_table :foursquare_users do |t|
      t.integer :person_id
      t.string :token, :limit => 50
      t.string :secret, :limit => 50
      t.string :arrival_status_text
      t.boolean :update_twitter, :default => 0
      t.boolean :update_facebook, :default => 0
      t.datetime :checked_in_at
      t.timestamps
    end
  end

  def self.down
    drop_table :foursquare_users
  end
end
