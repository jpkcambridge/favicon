require 'open-uri'
require 'nokogiri'

class Favicon < ActiveRecord::Base

  def self.find_favicon(home_page_url)
    favicon = Favicon.find_by(site_url: home_page_url)
    if favicon.present?
      favicon_url = favicon.favicon_url
    else
      self.fetch_favicon(home_page_url)
    end
  end

  def self.fetch_favicon(home_page_url)
    page_results = open(home_page_url)
    base_uri = page_results.base_uri
    site_url = "#{base_uri.scheme}://#{base_uri.host + base_uri.path}"
    favicon_url = site_url + '/favicon.ico'
    Favicon.create(site_url: site_url, favicon_url: favicon_url)
  end
end
