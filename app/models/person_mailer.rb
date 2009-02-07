class PersonMailer < ActionMailer::Base
  default_url_options[:host] = DEFAULT_HOST
  default_url_options[:port] = DEFAULT_PORT

  helper_method :protect_against_forgery?
  
  def confirmation(device)

    content_type "text/html" 

    recipients  device.person.email
    from        'The Hive <info@beehivebaltimore.org>'
    subject     "[Beehive Baltimore] Claiming Device #{device.mac}" 
    body        :device => device
  end
  
  def protect_against_forgery?
    false
  end
end
