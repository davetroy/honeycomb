module PeopleHelper

  def iterate_appearances_by_month(person)
    groups = person.grouped_appearances
    by_month = groups.keys.sort.reverse_each do |date|
      concat("<h3 style='color:black'>#{date.strftime('%B %Y')}</h3>")
      concat("<div style='background-color: white;color: black'>")
      appearances = groups[date] 
      concat("<p>#{appearances.group_by { |a| a.day_number }.keys.size } appearances</p>")

      concat("<ul>")

      weeks = groups[date].group_by { |d| d.first_seen_at.strftime("%W") }
      
      weeks.keys.sort.reverse_each do |week|
        concat("<li>Week #{week}: #{weeks[week].group_by { |a| a.day_number }.keys.size}</li>")
      end

      concat("</ul>")
      concat("</div>")
      return
    end
  end
end
