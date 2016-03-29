class HomeController < ApplicationController

  def dashboard
  end

  def import
    Favicon.import(params[:file])
    redirect_to root_path
  end

end
