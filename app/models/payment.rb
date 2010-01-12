class Payment < ActiveRecord::Base
  validates_presence_of :person_id
  validates_numericality_of :amount, :greater_than_or_equal_to => 0
  serialize :details

  # amount is stored in the database as an integer to avoid floating point issues,
  # so we have a getter and setter to normalize the amounts
  
  def amount
    read_attribute(:amount) / 100.0
  end

  def amount=(value)
    write_attribute(:amount,(value.to_f * 100).to_i)
  end
  
end