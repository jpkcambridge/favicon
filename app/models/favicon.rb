require 'timeout'
require 'open-uri'
require 'nokogiri'

class Favicon < ActiveRecord::Base

  def self.import(file)
    count = 0
    CSV.foreach(file.path, headers: false) do |row|
      begin
        Timeout::timeout(2) {
          self.find_favicon "http://#{row[1]}"
          count += 1
        }
      rescue
        logger.info "could not find #{row[1]}"
      end
      break if count > 5000
    end
  end

  def self.find_favicon(requested_url, get_fresh=false) #note requested_url is the result of user input and treatment by home_controller
    requested_url_host = URI.parse(requested_url).host
    if get_fresh
        self.fetch_favicon(requested_url)
    else
      favicon = Favicon.where(site_url_host: [requested_url_host, "www.#{requested_url_host}"]).last
      if favicon.present?
        favicon
      else
        self.fetch_favicon(requested_url)
      end
    end
  end

  def self.fetch_favicon(requested_url)
    page_results = open(requested_url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, :allow_redirections => :safe})
    base_uri = page_results.base_uri
    site_url_path = base_uri.path.length > 1 ? base_uri.path : ''
    site_url_scheme = base_uri.scheme
    site_url_host = base_uri.host

    site_url = "#{base_uri.scheme}://#{base_uri.host + site_url_path}"
    
    favicon_url = "#{base_uri.scheme}://#{base_uri.host}/favicon.ico"
    unless favicon_url_works?(favicon_url)
      favicon_url = fetch_link_tag_hreg(page_results)
    end

    Favicon.create(site_url_scheme: site_url_scheme, site_url_host: site_url_host, site_url_path: site_url_path, requested_url: requested_url, favicon_url: favicon_url)
  end

  def self.favicon_url_works?(favicon_url)
    result = open(favicon_url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, :allow_redirections => :safe}) rescue nil
    if result.present?
      true
    else
      false
    end
  end

  def self.fetch_link_tag_hreg(page_results)
    x = Nokogiri.HTML(page_results)
    x.css("link[rel*=icon]").attribute('href').value
    #TODO check for http in href value
  end
end
