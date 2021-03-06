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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140512150133) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "identities", force: true do |t|
    t.integer "user_id"
    t.string  "provider"
    t.string  "provider_id"
    t.string  "name"
    t.string  "real_name"
    t.string  "email"
  end

  add_index "identities", ["provider", "provider_id"], name: "index_identities_on_provider_and_provider_id", unique: true, using: :btree
  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "messages", force: true do |t|
    t.string   "unique_token"
    t.integer  "sender_id"
    t.string   "sender_email"
    t.integer  "recipient_id"
    t.string   "recipient_email"
    t.text     "cc_list"
    t.text     "bcc_list"
    t.string   "thread_id"
    t.string   "external_id"
    t.string   "external_source_id"
    t.string   "subject"
    t.text     "body"
    t.text     "body_html"
    t.datetime "opened_at"
    t.datetime "archived_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "mailgun_data"
    t.boolean  "display_in_iframe",  default: false
    t.integer  "source_id"
    t.string   "sender_name"
    t.string   "recipient_name"
  end

  add_index "messages", ["archived_at"], name: "index_messages_on_archived_at", using: :btree
  add_index "messages", ["external_id"], name: "index_messages_on_external_id", using: :btree
  add_index "messages", ["recipient_id", "sender_id"], name: "index_messages_on_recipient_id_and_sender_id", using: :btree
  add_index "messages", ["recipient_id"], name: "index_messages_on_recipient_id", using: :btree
  add_index "messages", ["sender_id", "recipient_id"], name: "index_messages_on_sender_id_and_recipient_id", using: :btree
  add_index "messages", ["sender_id"], name: "index_messages_on_sender_id", using: :btree
  add_index "messages", ["source_id"], name: "index_messages_on_source_id", using: :btree
  add_index "messages", ["thread_id"], name: "index_messages_on_thread_id", using: :btree
  add_index "messages", ["unique_token"], name: "index_messages_on_unique_token", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "user_name"
    t.string   "email"
    t.string   "real_name"
    t.text     "bio"
    t.string   "external_email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "automated"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["user_name"], name: "index_users_on_user_name", unique: true, using: :btree

end
