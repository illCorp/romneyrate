class CreateFacebookFriends < ActiveRecord::Migration
  def change
    create_table :facebook_friends do |t|
      t.references :facebook_user
      t.references :friend
      t.timestamps
    end
  end
end
