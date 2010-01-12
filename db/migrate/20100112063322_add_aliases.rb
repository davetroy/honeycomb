class AddAliases < ActiveRecord::Migration
  def self.up
    create_table :aliases do |t|
      t.integer :person_id
      t.string  :email
    end
  end

  def self.down
    drop_table :aliases
  end
end
