require 'open-uri'
require 'nokogiri'

class Favicon < ActiveRecord::Base

  def self.import(file)
    count = 0
    CSV.foreach(file.path, headers: false) do |row|
      self.find_favicon "http://#{row[1]}"
      count += 1
      break if count > 10
    end
  end

  def self.find_favicon(home_page_url)
    favicon = Favicon.find_by(site_url: home_page_url)
    if favicon.present?
      favicon_url = favicon.favicon_url
    else
      self.fetch_favicon(home_page_url)
    end
  end

  def self.fetch_favicon(home_page_url)
    page_results = open(home_page_url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, :allow_redirections => :safe})
    base_uri = page_results.base_uri
    site_url = "#{base_uri.scheme}://#{base_uri.host + base_uri.path}"
    favicon_url = site_url + '/favicon.ico'
    Favicon.create(site_url: site_url, favicon_url: favicon_url)
  end
end
