class AppearancesController < ApplicationController
  
  def index
    @appearances = Appearance.find(:all)
  end
  
end
