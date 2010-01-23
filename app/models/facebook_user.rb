class FacebookUser < ActiveRecord::Base
  belongs_to :person
  before_create { |record| record.email_hash = "#{Zlib.crc32(record.person.email)}_#{Digest::MD5.hexdigest(record.person.email)}" }
end
