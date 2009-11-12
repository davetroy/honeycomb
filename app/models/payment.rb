class Payment < ActiveRecord::Base
  validates_presence_of :person_id
  validates_numericality_of :amount, :greater_than_or_equal_to => 0
  serialize :details

  attr_accessible :details

end