class InvoiceMailer < ActionMailer::Base

  default_url_options[:host] = DEFAULT_HOST
  default_url_options[:port] = DEFAULT_PORT
  
  def initial_invoice(person,owed,paid,due)
    content_type "text/html"
    subject    '[Beehive Baltimore] Membership Invoice'
    recipients person.email
    from       'billing@beehivebaltimore.org'
    sent_on    Time.now
    
    body       :person => person, :owed => owed, :paid => paid, :due => due
  end

end
