require '../../config/environment.rb'
require 'fastercsv'

FasterCSV.foreach("paypal-20100626.csv") do |row|
  next unless row[4][/received/i]
  date, time, tz, name, amount, email, trans_id = [0,1,2,3,6,9,11].map { |i| row[i] }
  email = email.downcase.strip
  amt = amount.to_f * 100
  dt = Time.parse("#{date} #{time} #{tz}")
  person = Person.lookup(email) || Person.create(:email => email, :created_at => dt)
  next if person.payments.find(:first, :conditions => ['amount=? AND created_at BETWEEN ? and ?', amt, dt - 3.minutes, dt + 3.minutes])
  next if person.payments.find(:first, :conditions => ['amount=? AND created_at=?', amt, Time.parse(date)])
  puts "recording #{email} #{name} #{amount} #{trans_id}"
  person.payments.create!(:created_at => dt, :amount => amount.to_f, :state => 'Complete', :details => { :transaction_id => trans_id } )
end

