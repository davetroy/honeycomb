class PaymentAction < ActiveRecord::Base
  belongs_to :invoice
end