class CreateAppearances < ActiveRecord::Migration
  def self.up
    create_table :appearances do |t|
      t.integer :device_id
      t.string :ip_address
      t.timestamps
    end
  end

  def self.down
    drop_table :appearances
  end
end
