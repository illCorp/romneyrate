class FacebookUser < ActiveRecord::Base
  attr_accessible :uid, :name, :image_url, :raw_json
  has_many :sharing_actions
  has_and_belongs_to_many(:facebook_users,
      :join_table => "facebook_friends",
      :foreign_key => "facebook_user_id",
      :association_foreign_key => "friend_id")
  
  def permalink
    id.alphadecimal
  end
end
