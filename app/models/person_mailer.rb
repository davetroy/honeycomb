class PersonMailer < ActionMailer::Base
  default_url_options[:host] = DEFAULT_HOST
  default_url_options[:port] = DEFAULT_PORT

  helper_method :protect_against_forgery?
    
  def confirmation(device)
    content_type "text/html"
    recipients  device.person.email
    from        'Honeycomb <info@beehivebaltimore.org>'
    subject     "[Beehive Baltimore] Claiming Device #{device.mac}" 
    body        :device => device
  end
  
  def login_link(person)
    content_type "text/html"
    recipients  person.email
    from        'Honeycomb <info@beehivebaltimore.org>'
    subject     "[Beehive Baltimore] Reset your password"
    body        :person => person
  end

  def update_profile(person)
    content_type "text/html"
    recipients  person.email
    from        'Dave Troy <davetroy@gmail.com>'
    subject     "[Beehive Baltimore] Welcome to 2010 - Please setup your profile"
    body        :person => person
  end
  
  def protect_against_forgery?
    false
  end
end
