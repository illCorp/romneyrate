class FacebookUser < ActiveRecord::Base
  attr_accessible :uid, :name, :image_url, :raw_json
  has_many :sharing_actions
end
