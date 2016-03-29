class HomeController < ApplicationController

  def dashboard
  end

  def find_favicon
    Favicon.find_favicon(params[:site_url])
    redirect_to root_path
  end

  def import
    Favicon.import(params[:file])
    redirect_to root_path
  end

end
