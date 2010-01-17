require '../../config/environment.rb'
require 'fastercsv'

$people = {}

class PmtPerson
  attr :payments
  attr :name
  attr :email

  @@aliaslist = File.read("../aliases.txt").map { |f| f.strip.downcase.split(' ') }
  
  def self.find_by_email(email)
    return $people[email] if $people[email]
    matching_list = @@aliaslist.find { |alist| alist.find { |a| a==email } }
    if (matching_list && k = matching_list.find { |a| $people[a] })
      $people[k]
    else
      puts "can't find #{email}"
      raise
    end  
  end
  
  def initialize(email, name, pid=nil)
    @payments = {}
    @payments = []
    @email = email
    @name = name
    @pid = pid
  end
  
  def output
    @payments.sort { |a,b| a[:date] <=> b[:date] }.each do |p|
      puts "#{@pid},#{@email},#{p[:date].to_s(:short_date)},#{p[:amount]},#{p[:type]}"
    end
  end
end

#  0 "11/30/2009",
#  1 "05:35:51",
#  2 "PST",
#  3 "Peter Martucci",
#  4 "Payment Received",
#  5 "Completed",
#  6 "225.00",
#  7 "0.00",
#  8 "225.00",
#  9 "pmartucci@gmail.com",
# 10 "billing@beehivebaltimore.org",
# 11 "21B63634NC6839918",
# 12"Verified","","","","","","","","","","","","","","","","","","","","","","","","","","","",

Person.find(:all).each do |p|
  $people[p.email] = PmtPerson.new(p.email.strip, "#{p.first_name} #{p.last_name}".strip, p.id)
end

FasterCSV.foreach("paypal2.csv") do |row|
  next unless row[4][/received/i]
  date, time, tz, name, amount, email = [0,1,2,3,6,9].map { |i| row[i] }
  email = email.downcase.strip
  $people[email] = PmtPerson.find_by_email(email) #|| PmtPerson.new(email, name)
  person = $people[email]
  person.payments << {:date => Time.parse("#{date} #{time} #{tz}"), :amount => amount.to_f, :type => 'paypal'}
end

# gallagher.sean.m@gmail.com	Sean Gallagher	45	25	25	25

# FasterCSV.foreach("other.csv") do |row|
#   next if row[0].nil?
#   email, name = row[0..1]
#   email = email.downcase.strip
#   pmts = row[2..-1]
#   $people[email] = PmtPerson.find_by_email(email) #|| PmtPerson.new(email, name)
#   person = $people[email]
#   billdate = Time.parse('2/1/2009')
#   pmts.each do |p|
#     person.payments << {:date => billdate, :amount => p.to_f, :type => 'other'} if (p.to_f>0)
#     billdate = 1.month.from_now(billdate)
#   end
# end

#p @people.values
plist = $people.values.uniq.sort { |a,b| a.name <=> b.name }
plist.each { |p| p.output }
