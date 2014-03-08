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

ActiveRecord::Schema.define(version: 20140307223309) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "addresses", force: true do |t|
    t.string   "line1"
    t.string   "line2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.integer  "addressable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "addressable_type"
  end

  create_table "characters", force: true do |t|
    t.string   "name"
    t.integer  "delegation_id"
    t.integer  "committee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committee_type_selections", force: true do |t|
    t.integer  "committee_type_id"
    t.integer  "delegation_id"
    t.integer  "delegate_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committee_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committees", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: true do |t|
    t.string   "name"
    t.integer  "delegation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "country_committees", force: true do |t|
    t.integer  "country_id"
    t.integer  "committee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "changer_id"
  end

  add_index "country_committees", ["changer_id"], name: "index_country_committees_on_changer_id", using: :btree

  create_table "delegation_field_values", force: true do |t|
    t.integer "delegation_field_id"
    t.text    "value"
    t.integer "delegation_id"
  end

  add_index "delegation_field_values", ["delegation_field_id"], name: "index_delegation_field_values_on_delegation_field_id", using: :btree
  add_index "delegation_field_values", ["delegation_id"], name: "index_delegation_field_values_on_delegation_id", using: :btree

  create_table "delegation_fields", force: true do |t|
    t.string  "name"
    t.string  "slug"
    t.string  "class_name"
    t.integer "delegation_page_id"
    t.boolean "multiple"
    t.boolean "active"
    t.integer "position"
    t.string  "options"
    t.text    "description"
  end

  create_table "delegation_pages", force: true do |t|
    t.string  "name"
    t.integer "step"
  end

  create_table "delegations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "step"
    t.string   "payment_currency"
    t.string   "payment_type"
  end

  create_table "options", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "class_name"
  end

  create_table "payments", force: true do |t|
    t.integer  "delegation_id"
    t.string   "payer_id"
    t.string   "payment_id"
    t.float    "amount"
    t.string   "sale_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "currency"
    t.string   "method"
  end

  create_table "preferences", force: true do |t|
    t.integer  "country_id"
    t.integer  "delegation_id"
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "type"
    t.integer  "delegation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
