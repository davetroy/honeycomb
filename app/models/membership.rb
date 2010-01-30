class Membership < ActiveRecord::Base
  validates_presence_of :start_date
  belongs_to :person
  belongs_to :plan
  has_many :invoices

  before_save :set_defaults
  
  named_scope :active, lambda { { :conditions => ['start_date <= ? AND ((end_date IS NULL) OR (end_date > ?))', Time.now, Time.now] } }
  named_scope :unbilled, lambda { { :conditions => ['(billed_through < ?) OR (billed_through IS NULL)', Time.now] } }
  
  def set_defaults
    self.start_date ||= Time.now
  end

  def invoice_appearance(a)
    p "billing appearance"
  end
  
  def date_range
    "#{start_date.to_s(:short_date)} &ndash; #{(end_date || Time.now).to_s(:short_date)}"
  end

end
