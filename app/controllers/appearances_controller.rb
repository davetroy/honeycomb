class AppearancesController < ApplicationController
  
  def index
    @appearances = Appearance.recent
  end
  
end
