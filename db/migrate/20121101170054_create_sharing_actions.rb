class CreateSharingActions < ActiveRecord::Migration
  def change
    create_table :sharing_actions do |t|
      t.string :network
      t.text :body
      t.references :facebook_user
      t.timestamps
    end
  end
end
