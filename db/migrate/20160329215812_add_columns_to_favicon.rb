class AddColumnsToFavicon < ActiveRecord::Migration
  def change
    add_column :favicons, :site_url_scheme, :string
    add_column :favicons, :site_url_host, :string
    add_column :favicons, :site_url_path, :string
    add_column :favicons, :requested_url, :string
  end
end
