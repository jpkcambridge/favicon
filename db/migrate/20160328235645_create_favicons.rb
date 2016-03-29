class CreateFavicons < ActiveRecord::Migration
  def change
    create_table :favicons do |t|
      t.string :site_url
      t.string :favicon_url

      t.timestamps null: false
    end
  end
end
