require 'open-uri'
require 'nokogiri'

class Favicon < ActiveRecord::Base

  def self.import(file)
    count = 0
    CSV.foreach(file.path, headers: false) do |row|
      begin
        self.find_favicon "http://#{row[1]}"
        count += 1
      rescue
        logger.info "could not find #{row[1]}"
      end
      break if count > 10
    end
  end

  #TODO add get fresh option to do another lookup even if one exists in db
  def self.find_favicon(requested_url) #note requested_url is the result of user input and treatment by home_controller
    requested_url_host = URI.parse(requested_url).host
    favicon = Favicon.where(site_url_host: [requested_url_host, "www.#{requested_url_host}"]).last
    if favicon.present?
      favicon
    else
      self.fetch_favicon(requested_url)
    end
  end

  def self.fetch_favicon(requested_url)
    page_results = open(requested_url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, :allow_redirections => :safe})
    base_uri = page_results.base_uri
    site_url_path = base_uri.path.length > 1 ? base_uri.path : ''
    site_url_scheme = base_uri.scheme
    site_url_host = base_uri.host

    site_url = "#{base_uri.scheme}://#{base_uri.host + site_url_path}"
    
    #TODO check for size of favicon, if 0 look for link tags on page and grab one
    favicon_url = "#{base_uri.scheme}://#{base_uri.host}/favicon.ico"

    Favicon.create(site_url_scheme: site_url_scheme, site_url_host: site_url_host, site_url_path: site_url_path, requested_url: requested_url, favicon_url: favicon_url)
  end
end
