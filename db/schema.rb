# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_01_20_125132) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.integer "giver_id"
    t.integer "receiver_id"
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_assignments_on_group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "group_name"
    t.bigint "user_id", null: false
    t.decimal "budget"
    t.string "event_name"
    t.datetime "event_date"
    t.string "group_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_groups_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.bigint "wishlist_id", null: false
    t.string "item_name"
    t.decimal "price"
    t.text "description"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wishlist_id"], name: "index_items_on_wishlist_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.integer "sender_id"
    t.integer "receiver_id"
    t.text "message"
    t.boolean "is_anonymous"
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_messages_on_group_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.bigint "user_id", null: false
    t.text "message"
    t.string "notification_type"
    t.boolean "is_read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "participants", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.boolean "is_admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_participants_on_group_id"
    t.index ["user_id"], name: "index_participants_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  create_table "wishlists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_wishlists_on_group_id"
    t.index ["user_id"], name: "index_wishlists_on_user_id"
  end

  add_foreign_key "assignments", "groups"
  add_foreign_key "groups", "users"
  add_foreign_key "items", "wishlists"
  add_foreign_key "messages", "groups"
  add_foreign_key "notifications", "users"
  add_foreign_key "participants", "groups"
  add_foreign_key "participants", "users"
  add_foreign_key "wishlists", "groups"
  add_foreign_key "wishlists", "users"
end
