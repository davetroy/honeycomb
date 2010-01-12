namespace :honey do
  namespace :load do
    desc 'Load manufacturer data'
    task :manufacturers => :environment do
      File.readlines(File.dirname(__FILE__) + '/../../db/data/oui.txt').each do |line|
        line.grep(/\(hex\)/).each do |l|
          l.chomp!
          mac, manufacturer_name = l.split(/\s+\(hex\)\s+/).each { |part| part.strip }
          mac.gsub!(/-/, ':')
          Manufacturer.find_or_create_by_mac_identifier(:mac_identifier => mac, :name => manufacturer_name)
        end
      end
    end
  end
end