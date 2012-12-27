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

ActiveRecord::Schema.define(:version => 20121226194702) do

  create_table "authorizations", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "secret"
    t.string   "token"
  end

  create_table "geo_events", :force => true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "begins_utc"
    t.datetime "expires_utc"
    t.string   "text"
    t.float    "duration"
    t.string   "category"
    t.string   "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_events", ["latitude"], :name => "index_geo_events_on_latitude"
  add_index "geo_events", ["longitude"], :name => "index_geo_events_on_longitude"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.float    "max_squeak_duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "share_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "squeak_id"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "squeaks", :force => true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "time_utc"
    t.string   "text"
    t.datetime "expires"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "gmaps"
    t.string   "user_email"
    t.float    "duration"
    t.integer  "user_id"
    t.binary   "image"
    t.string   "timezone"
    t.string   "category"
    t.string   "source"
  end

  add_index "squeaks", ["created_at"], :name => "index_squeaks_on_created_at"
  add_index "squeaks", ["latitude"], :name => "index_squeaks_on_latitude"
  add_index "squeaks", ["longitude"], :name => "index_squeaks_on_longitude"
  add_index "squeaks", ["user_email"], :name => "index_squeaks_on_user_email"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
    t.integer  "role_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
