class AddStatsToFacebookUsers < ActiveRecord::Migration
  def change
    add_column :facebook_users, :num_friends, :integer
    add_column :facebook_users, :romney_rate, :float
  end
end
