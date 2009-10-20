class Membership < ActiveRecord::Base
  belongs_to :person
  belongs_to :plan
  has_many :bills

  before_save :set_defaults
  after_create :do_billing
  
  named_scope :active, lambda { { :conditions => ['start_date <= ? AND ((end_date IS NULL) OR (end_date > ?))', Time.now, Time.now] } }
  named_scope :unbilled, lambda { { :conditions => ['(billed_through < ?) OR (billed_through IS NULL)', Time.today] } }
  
  def set_defaults
    self.start_date ||= Time.today
  end

  def do_billing
    base_date = billed_through || start_date
    stop_date = end_date || Time.today
    monthcount = 0
    bill_date = base_date
    while (bill_date <= stop_date)
      bills.create(:amount => plan.price, :created_at => bill_date)
      monthcount += 1
      bill_date = base_date + monthcount.month
    end
  end

  def bill_appearance(a)
    p "billing appearance"
  end
end
