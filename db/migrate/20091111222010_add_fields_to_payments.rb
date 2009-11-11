class AddFieldsToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :amount, :integer, :null => false, :default => 0
    add_column :payments, :token, :string
    add_column :payments, :state, :string, :null => false, :default => "New"
    add_column :payments, :details, :string
    add_index :payments, :token
  end

  def self.down
    remove_column :payments, :token
    remove_column :payments, :amount
  end
end
