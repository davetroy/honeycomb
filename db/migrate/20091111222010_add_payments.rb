class AddPayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :person_id
      t.integer :amount, :null => false, :default => 0
      t.string  :token
      t.string  :state, :null => false, :default => "New"
      t.string  :details
      t.timestamps
    end

    add_index :payments, :token
  end

  def self.down
    drop_table :payments
  end
end
