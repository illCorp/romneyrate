class SharingAction < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :facebook_user
end
