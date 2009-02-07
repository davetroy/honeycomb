class DevicesController < ApplicationController

  def claim
    @device = Device.find(params[:id])
    @person = Person.new
  end
  
  def assign
    email = params[:person][:email]
    @device = Device.find(params[:id])
    @device.assign(email)
    flash.now[:notice] = "A confirmation email has been sent to <strong>#{email}</strong>."
    redirect_to :controller => 'appearances'
  end
end