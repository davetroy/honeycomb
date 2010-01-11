class PeopleController < ApplicationController
  
  def confirm_device_for
    if (@person = Person.find(params[:id])) && (@device = Device.find(params[:device_id]))
      @device.update_attribute(:person_verified, true) if (@device.person_id == @person.id && @device.confirmation_key == params[:key])
      flash.now[:notice] = "Device #{@device.mac} has been claimed by #{@person.email}!"
    end
    
    if @person.is_setup?
      redirect_to root_path
    else
      redirect_to edit_person_path(@person)
    end
  end

  def edit
    @person = Person.find(params[:id])
    render :status => 404 unless params[:key]==@person.temporary_key
  end
  
  def update
    @person = Person.find(params[:id])
    @person.update_attributes(params[:person])
    flash.now[:notice] = "Updates saved!"
    redirect_to root_path
  end
  
  # member directory
  def index
    @people = Person.find(:all).sort { |a,b| b.days.size <=> a.days.size }
  end
  
  def show
    @person = Person.find(params[:id])
    render params[:type] if params[:type]
  end
    
  def destroy
    Person.find(params[:id]).destroy
    redirect_to people_path
  end
      
end