class AddPeopleAttributes < ActiveRecord::Migration
  def self.up
    add_column :people, :password_hash, :string, :limit => 50
    add_column :people, :company_name, :string
    add_column :people, :phone_number, :string
    add_column :people, :website, :string
    add_column :people, :profile, :text
    add_column :people, :allow_contact, :boolean
    add_column :people, :membership_plan, :integer
  end

  def self.down
    remove_column :people, :twitter_username
    remove_column :people, :membership_plan
  end
end
