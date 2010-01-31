class AddMembershipFields < ActiveRecord::Migration
  def self.up
    add_column :memberships, :amount_due, :integer
  end

  def self.down
    remove_column :memberships, :amount_due
  end
end
