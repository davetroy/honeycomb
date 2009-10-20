class PeoplePrize < ActiveRecord::Base
  belongs_to :person
  has_many :prizes
end