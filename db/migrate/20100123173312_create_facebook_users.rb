class CreateFacebookUsers < ActiveRecord::Migration
  def self.up
    create_table :facebook_users do |t|
      t.integer :person_id
      t.string :email_hash
      t.integer :fb_uid
      t.string :arrival_status_text
      t.datetime :checked_in_at
      t.timestamps
    end
  end

  def self.down
    drop_table :facebook_users
  end
end
