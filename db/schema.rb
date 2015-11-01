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

ActiveRecord::Schema.define(version: 20151104013300) do

  create_table "companies", force: :cascade do |t|
    t.string   "symbol",     limit: 5
    t.string   "name",       limit: 255
    t.string   "sector",     limit: 255
    t.string   "industry",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "companies", ["symbol"], name: "index_companies_on_symbol", unique: true, using: :btree

  create_table "favorite_companies", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "company_id", limit: 4
    t.boolean  "active",               default: true, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "favorite_companies", ["company_id"], name: "index_favorite_companies_on_company_id", using: :btree
  add_index "favorite_companies", ["user_id"], name: "index_favorite_companies_on_user_id", using: :btree

  create_table "finance_caches", force: :cascade do |t|
    t.text     "hist_data",  limit: 65535
    t.text     "curr_data",  limit: 65535
    t.integer  "status",     limit: 4,     default: 0
    t.integer  "company_id", limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "finance_caches", ["company_id"], name: "index_finance_caches_on_company_id", unique: true, using: :btree

  create_table "sentiment_caches", force: :cascade do |t|
    t.datetime "tweet_when"
    t.decimal  "score",                    precision: 6, scale: 3
    t.string   "tweet_text",   limit: 255
    t.string   "tweet_author", limit: 255
    t.integer  "num_tweets",   limit: 4
    t.integer  "company_id",   limit: 4
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "sentiment_caches", ["company_id"], name: "index_sentiment_caches_on_company_id", unique: true, using: :btree

  create_table "favorite_companies", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "company_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "favorite_companies", ["company_id"], name: "index_favorite_companies_on_company_id", using: :btree
  add_index "favorite_companies", ["user_id"], name: "index_favorite_companies_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "finance_caches", "companies"
  add_foreign_key "sentiment_caches", "companies"
end
