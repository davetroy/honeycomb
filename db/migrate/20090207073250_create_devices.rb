class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.string :name
      t.string :mac
      t.integer :appearance_id
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :devices
  end
end
