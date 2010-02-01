class Plan < ActiveRecord::Base
  has_many :memberships
  
  def included_days_per_month
    days_per_month || (days_per_week * 4.5).to_i
  end
  
end
