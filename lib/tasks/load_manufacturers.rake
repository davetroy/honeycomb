namespace :db do
  namespace :load do
    desc 'Initialize manufacturer info'
    task :manufacturers => :environment do
      Manufacturer.connection.execute('TRUNCATE TABLE manufacturers')
      File.readlines(File.dirname(__FILE__) + '/../../db/data/oui.txt').each do |line|
        line.grep(/\(hex\)/).each do |l|
          l.chomp!
          mac, manufacturer_name = l.split(/\s+\(hex\)\s+/).each { |part| part.strip }
          mac.gsub!(/-/, ':')
          Manufacturer.create(:mac_identifier => mac, :name => manufacturer_name)
        end
      end
    end
  end
end