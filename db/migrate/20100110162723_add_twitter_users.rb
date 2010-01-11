class AddTwitterUsers < ActiveRecord::Migration
  def self.up
    create_table :twitter_users do |t|
      t.string :username
      t.integer :person_id
      t.string :token, :limit => 50
      t.string :secret, :limit => 50
      t.string :arrival_status_text
      t.datetime :checked_in_at
      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_users
  end
end
