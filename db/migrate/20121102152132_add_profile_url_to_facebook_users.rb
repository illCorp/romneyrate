class AddProfileUrlToFacebookUsers < ActiveRecord::Migration
  def change
    add_column :facebook_users, :profile_url, :string
  end
end
