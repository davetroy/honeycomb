module PeopleHelper

  def iterate_appearances_by_month(person)
    groups = person.grouped_appearances
    
    by_month = groups.keys.sort.reverse_each do |date|
      concat("<h3 style='color:black'>#{date.strftime('%B %Y')}</h3>")
      concat("<div style='background-color: white;color: black;padding:0.25em 0 0.25em 0.5em;width:50%;'>")
      appearances = groups[date] 
      concat("<p>#{appearances.group_by { |a| a.day_number }.keys.size } appearances</p>")

      concat("<ul>")

      weeks = groups[date].group_by { |d| d.first_seen_at.strftime("%W") }

      monthly_appearances = 0
      excess_weekly_appearances = 0
      
      weeks.keys.sort.reverse_each do |week|
        appearances_this_week = weeks[week].group_by { |a| a.day_number }.keys.size
        concat("<li>Week #{week}: #{appearances_this_week}</li>")
        monthly_appearances += appearances_this_week

        if appearances_this_week > 3
          excess_weekly_appearances += (appearances_this_week-3)
        end
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
