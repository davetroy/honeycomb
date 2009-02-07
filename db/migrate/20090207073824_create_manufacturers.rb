class CreateManufacturers < ActiveRecord::Migration
  def self.up
    create_table :manufacturers do |t|
      t.string :mac_identifier
      t.string :name

      t.timestamps
    end
    
    add_index :manufacturers, :mac_identifier, :unique => true
    add_index :manufacturers, :name
  end

  def self.down
    drop_table :manufacturers
  end
end
