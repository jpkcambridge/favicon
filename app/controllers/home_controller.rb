class HomeController < ApplicationController
  before_filter :reset_errors


  def dashboard
    if params[:favicon_id].present?
      @favicon = Favicon.find(params[:favicon_id])
    end
  end

  def favicon_index
  end

  def find_favicon
    # check if valid
    unless  valid_url?(params[:site_url])
      @errors << "Please enter a valid url."
      render :dashboard and return
    end
    site_url = massage_url(params[:site_url])
    favicon = Favicon.find_favicon(site_url)
    redirect_to root_path(favicon_id: favicon.id)
  end

  def import
    Favicon.import(params[:file])
    redirect_to root_path
  end

  def valid_url?(site_url)
    return false unless site_url.include?('.')
    true
  end

  def massage_url(site_url)
    # TODO make more robust, such as checking for colon and forward slashes
    return site_url if site_url.include?('http')
    return "http://#{site_url}"
  end

  def reset_errors
    @errors = []
  end

end
