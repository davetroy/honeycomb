require 'money'

class PaymentsController < ApplicationController  

  include ActionView::Helpers::NumberHelper # for number_to_currency

  verify :params => :person_id, :render => :error, :add_flash => { :notice => "You must specify a person ID" }, :only => :new
  verify :params => :token, :redirect_to => :new_payment_url, :only => [:confirm]
  before_filter :find_payment, :only => [:confirm, :complete,:thanks]
  before_filter :validate_ipn, :only => [:ipn]
  before_filter :find_ipn_person, :only => [:ipn]

  skip_before_filter :verify_authenticity_token, :only => [:ipn]

  # NB amount is always in pennies
  def new
    @payment = Payment.new(:person_id => params[:person_id],:amount => params[:amount].blank? ? 0.0 : params[:amount].to_f / 100.0)
    @person_id = params[:person_id]
  end
  
  def create
    @payment = Payment.create(params[:payment])

    if @payment.valid?
      setup_response = gateway.setup_purchase(@payment.integer_amount,
        :ip                => request.remote_ip,
        :return_url        => confirm_payment_url(@payment),
        :cancel_return_url => new_payment_url(:amount => @payment.amount, :person_id => @payment.person_id),
        :order_id => @payment.id,
        :customer => @payment.person_id,
        :description => "Beehive Baltimore direct payment from #{@payment.person_show_name}"
      )
      logger.info("Created pending payment #{@payment.id} for person #{@payment.person_id} (#{@payment.person_show_name}) for #{number_to_currency(@payment.amount)}, token #{setup_response.token}")
      @payment.update_attribute(:token,setup_response.token)
      redirect_to gateway.redirect_url_for(setup_response.token)
    else
      render :action => :error
    end
  end
    
  def confirm
    details_response = gateway.details_for(params[:token])

    if details_response.success?
      @address = details_response.address
      state = "Success"
      logger.info("Confirmed payment #{@payment.id} for person #{@payment.person_id} (#{@payment.person_show_name}) for #{number_to_currency(@payment.amount)}; details: '#{details_response.inspect}'")
    else
      flash.now[:notice] = details_response.message
      state = "Error"
      logger.warn("Could not confirm payment #{@payment.id} for person #{@payment.person_id} (#{@payment.person_show_name}) for #{number_to_currency(@payment.amount)}; details: '#{details_response.inspect}'")
      render :action => 'error'
    end

    @payment.update_attributes(:details => details_response,:state => state)
  end

  def complete
    # it's okay to modify the amount from what was originally sent to paypal    
    @amount = params[:payment][:amount].to_i
    @payment.update_attribute(:amount,@amount)

    # TODO switch amount to a Money object
    purchase = gateway.purchase(@payment.integer_amount,
      :ip       => request.remote_ip,
      :payer_id => params[:payer_id],
      :token    => params[:token]
    )


    if purchase.success?
      @payment.update_attribute(:state,"Complete")
      logger.info("Completed payment #{@payment.id} for person #{@payment.person_id} (#{@payment.person_show_name}) for #{number_to_currency(@payment.amount)}")
      redirect_to thanks_payment_url(@payment)
    else
      @payment.update_attribute(:state,purchase.message)
      flash.now[:notice] = "There was a problem with your purchase: #{purchase.message}"
      logger.warn("Could not complete payment #{@payment.id} for person #{@payment.person_id} (#{@payment.person_show_name}) for #{number_to_currency(@payment.amount)} due to #{purchase.message}")
      render :action => 'error'
    end
  end

  # captures payments that originated from Paypal, not from within our site
  
  def ipn
    if @notification.complete?
      Payment.create!(:person_id => @person.id, :amount => @notification.amount,:token => params[:txn_id],:state => "Complete") 
      logger.info("Created payment for person #{@person.id} for #{@notification.amount}")
    else
      logger.warn("Received an incomplete IPN notification from Paypal: #{@notification.inspect}")
    end
    render :nothing => true
  rescue
    logger.error("Received Paypal IPN notification #{@notification.inspect} for #{@person.inspect} but could not record the payment due to #{$!.message} at #{$!.backtrace.join(',')}")
    render :nothing => true, :status => 500
  end

  private

  def validate_ipn
    @notification = ActiveMerchant::Billing::Integrations::Paypal::Notification.new(request.raw_post)
    unless @notification.acknowledge
      logger.error("Received unverified IPN payment notification, ignoring: #{@notification.inspect}")
      render :nothing => true
    end
  end

  def find_ipn_person
    payer_email = @notification.params['payer_email']
    @person = Person.lookup(payer_email) || Person.create(:email => payer_email)
    logger.warn("Received Paypal IPN payment notification for new user: #{payer_email}")
  end

  def find_payment
    @payment = params[:token] ? Payment.find_by_token(params[:token]) : Payment.find_by_id(params[:id])
    if @payment.nil?
      flash.now[:notice] = "Could not find that payment"
      render :action => 'error', :status => 404
    end
  end
  
  def gateway
    @gateway ||= ActiveMerchant::Billing::PaypalExpressGateway.new(PAYPAL_CREDS)
  end

end
