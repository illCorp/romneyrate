class CreateFacebookUsers < ActiveRecord::Migration
  def change
    create_table :facebook_users do |t|
      t.string :uid
      t.string :name
      t.string :image_url
      t.text :description
      t.string :link
      t.text :raw_json
      t.timestamps
    end
  end
end
