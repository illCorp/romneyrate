# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121102011631) do

  create_table "facebook_friends", :force => true do |t|
    t.integer  "facebook_user_id"
    t.integer  "friend_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "facebook_users", :force => true do |t|
    t.string   "uid"
    t.string   "name"
    t.string   "image_url"
    t.text     "description"
    t.string   "link"
    t.text     "raw_json"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "num_friends"
    t.float    "romney_rate"
  end

  create_table "sharing_actions", :force => true do |t|
    t.string   "network"
    t.text     "body"
    t.integer  "facebook_user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

end
