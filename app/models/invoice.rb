class Invoice < ActiveRecord::Base
  belongs_to :membership
  has_many :line_items
  has_many :payment_actions
end