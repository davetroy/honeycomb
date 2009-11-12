class PaymentsController < ApplicationController  
  verify :params => :person_id, :render => :error, :add_flash => { :notice => "You must specify a person ID" }, :only => :new
  verify :params => :token, :redirect_to => :new_payment_url, :only => [:confirm]
  before_filter :find_payment, :only => [:confirm, :complete]
  
  # NB amount is always in pennies
  def new
    @payment = Payment.new
    @payment.person_id = params[:person_id]
    @payment.amount = params[:amount] || 0
  end
  
  def create
    @payment = Payment.new
    @payment.amount = params[:payment][:amount]
    @payment.person_id = params[:payment][:person_id]

    if @payment.save && response = setup_purchase
      @payment.token = response.token
      @payment.save!
      redirect_to gateway.redirect_url_for(@payment.token)
    else
      flash.now[:notice] = "There was a problem with your payment. Please try again."
      render :action => :error
    end
  end
    
  def confirm    
    if details_response = get_details
      if details_response.success?
        @address = details_response.address
        state = "Success"
      else
        flash.now[:notice] = details_response.message
        state = "Error"
        render :action => 'error'
      end

      @payment.state = state
      @payment.details = details_response
    else
      @payment.state = "Unable to confirm; bad response from paypal"
      flash[:notice] = "There was a problem with confirming your payment. Please try again."
      redirect_to new_payment_url(:person_id => @payment.person_id,:amount => @payment.amount)
    end

    @payment.save!
  end

  def complete
    # it's okay to modify the amount from what was originally sent to paypal    
    @payment.amount = params[:payment][:amount].to_i
    
    if purchase = complete_purchase(@payment.amount)
      if purchase.success?
        @payment.state = "Complete"
      else
        @payment.state = "ERROR: #{purchase.message}"
        flash.now[:notice] = "There was a problem with your purchase: #{purchase.message}"
        render :action => 'error'
      end
    else
      @payment.state = "Unable to complete; bad response from paypal"
      flash[:notice] = "There was a problem with confirming your payment. Please try again."
      redirect_to new_payment_url(:person_id => @payment.person_id,:amount => @payment.amount)      
    end
    
    @payment.save!
  end
  
  private

  def complete_purchase(amount)
    begin
      gateway.purchase(amount,
        :ip       => request.remote_ip,
        :payer_id => params[:payer_id],
        :token    => params[:token])
    rescue StandardError
      logger.error("Unable to get complete Paypal purchase due to #{$!.message}")
      nil
    end
  end
  
  def get_details
    begin
      gateway.details_for(params[:token])
    rescue StandardError
      logger.error("Unable to get details for Paypal purchase due to #{$!.message}")
      nil
    end
  end
  
  def setup_purchase
    begin
      gateway.setup_purchase(@payment.amount,
        :ip                => request.remote_ip,
        :return_url        => confirm_payment_url(@payment),
        :cancel_return_url => new_payment_url(:amount => @payment.amount, :person_id => @payment.person_id)
      )
    rescue StandardError
      logger.error("Unable to setup Paypal purchase due to #{$!.message}")
      nil
    end
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