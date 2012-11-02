class FacebookFriend < ActiveRecord::Base
attr_accessible :facebook_user_id, :friend_id
  belongs_to :facebook_user
  belongs_to :friend, :class_name => 'FacebookUser'
end
