class Invoice < ActiveRecord::Base
  validates_presence_of :amount,:person
  
  belongs_to :person
  has_many :line_items
  has_many :payment_actions

  # amount is stored in the database as an integer to avoid floating point issues,
  # so we have a getter and setter to normalize the amounts
  
  named_scope :descending, :order => 'id DESC'
    
  def amount
    read_attribute(:amount) / 100.0
  end

  def amount=(value)
    write_attribute(:amount,(value.to_f * 100).to_i)
  end

end