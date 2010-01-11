class Plan < ActiveRecord::Base
  has_many :memberships

  def compute_bill(daily_appearances)
    monthly_appearances = daily_appearances.size

    # ruby's Date class doesn't have a "week number" function and I don't want to screw up writing my own
    grouped_by_week = daily_appearances.group_by { |a| a.strftime("%W") } 

    excess_weekly_appearances = 0    
    grouped_by_week.each do |week,appearances|
      weekly_appearances = appearances.size
      excess_weekly_appearances += (weekly_appearances-3) if weekly_appearances > 3
    end

    # HACK gross use of a case statement.  If individual plans have more customized behavior than this, 
    # probably worth busting into STI classes

    case name
    when "Basic"
      fee = 25.0 + (monthly_appearances > 1 ? (monthly_appearances-1)*15 : 0)
    when "Worker Bee"
      fee = 175.0 + (excess_weekly_appearances*15)
    when "Resident"
      275.0
    end
  end
end
