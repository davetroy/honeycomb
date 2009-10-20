class AddPlans < ActiveRecord::Migration
  def self.up
    create_table :plans do |t|
      t.string :name
      t.float :deposit
      t.float  :price
      t.string :period, :limit => 1
      t.integer :days_per_week
      t.integer :days_per_month
      t.float  :price_per_day, :default => 15
      t.timestamps
    end
        
    create_table :memberships do |t|
      t.integer :person_id
      t.integer :plan_id
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :billed_through
    end
    
    create_table :invoices do |t|
      t.integer :person_id
      t.integer :membership_id
      t.integer :amount
      t.timestamps
    end
    
    create_table :payments do |t|
      t.integer :person_id
      t.timestamps
    end
    
  end

  def self.down
    drop_table :plans
    drop_table :memberships
    drop_table :invoices
  end
end