class Alias < ActiveRecord::Base
  belongs_to :person
  validates_uniqueness_of :email
end