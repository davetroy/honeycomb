module PeopleHelper

  def iterate_appearances_by_month(person)
    person.appearance_range.reverse_each do |month,year|
      concat("<h3 style='color:black'>#{Time::RFC2822_MONTH_NAME[month-1]} #{year}</h3>")
      concat("<div style='background-color: white;color: black;padding:0.25em 0 0.25em 0.5em;width:50%;'>")
      monthly_appearances = person.daily_appearance_dates(month,year).size
      concat("<p>#{monthly_appearances} appearances</p>")

      concat("<ul>")

      excess_weekly_appearances = 0
      
      person.daily_appearances_by_week(month,year).each do |week,appearances|
        weekly_appearances = appearances.size
        concat("<li>Week #{week}: #{weekly_appearances}</li>")
        excess_weekly_appearances += (weekly_appearances-3) if weekly_appearances > 3
      end

      concat("</ul>")
      concat("<p>")

      fee = 25 + (monthly_appearances > 1 ? (monthly_appearances-1)*15 : 0)
      concat("As a Basic Member, you would owe: #{number_to_currency(fee)}.<br/>")

      fee = 175+(excess_weekly_appearances*15)
      concat("As a Worker Bee, you would owe: #{number_to_currency(fee)}.<br/>")

      fee = 275
      concat("As a Beehive Resident, you would owe: #{number_to_currency(fee)}.</p>")
    
      concat("</div>")
    end
    return
  end
end
