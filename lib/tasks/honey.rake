namespace :honey do
  namespace :billing do
    desc "Generate invoices"
    task :generate => :environment do
      Person.members.each do |person|
        person.send_invoice_for_total_owed
      end
    end
    
    desc "New Members"
    task :new_members => :environment do
      Person.drop_ins.each do |person|
        puts person.email
      end
    end
  end
  
  
  
  namespace :load do        
    desc "Load email aliases"
    task :aliases => :environment do
      IO.readlines("#{RAILS_ROOT}/db/aliases.txt").each do |line|
        aliases = line.strip.split
        person = nil
        aliases.find { |a| person=Person.find_by_email(a) }
        add_aliases = aliases - [person.email]
        add_aliases.each do |a|
          person.aliases.find_or_create_by_email(a)
          puts "#{person.id} = #{a}"
        end
      end
    end
  end
end