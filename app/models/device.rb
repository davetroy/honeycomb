class Device < ActiveRecord::Base
  belongs_to :person
  has_many :appearances
  has_one :manufacturer, :foreign_key => 'mac_identifier', :primary_key => :manufacturer_id
  
  def manufacturer_id
    mac[0..7]
  end
  
end
