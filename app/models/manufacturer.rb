class Manufacturer < ActiveRecord::Base
  has_many :devices, :finder_sql => 'SELECT * FROM devices WHERE LEFT(mac,8)=\'#{mac_identifier}\''
  
  validates_uniqueness_of :mac_identifier
  
  before_save { |record| record.name.capitalize_words! }
end
