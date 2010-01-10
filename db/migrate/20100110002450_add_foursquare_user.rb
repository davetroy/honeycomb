class AddFoursquareUser < ActiveRecord::Migration
  def self.up
    create_table :foursquare_users do |t|
      t.integer :person_id
      t.string :token, :limit => 50
      t.string :secret, :limit => 50
      t.boolean :update_twitter
      t.boolean :update_facebook
    end
  end

  def self.down
    drop_table :foursquare_user
  end
end
