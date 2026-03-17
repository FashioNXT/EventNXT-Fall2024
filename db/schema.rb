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

ActiveRecord::Schema[7.0].define(version: 2026_02_28_001643) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "email_services", force: :cascade do |t|
    t.string "to"
    t.string "subject"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "sent_at"
    t.datetime "committed_at"
    t.bigint "event_id"
    t.bigint "guest_id"
    t.integer "email_template_id"
    t.index ["event_id"], name: "index_email_services_on_event_id"
    t.index ["guest_id"], name: "index_email_services_on_guest_id"
  end

  create_table "email_templates", force: :cascade do |t|
    t.string "name", null: false
    t.text "subject"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.string "address"
    t.string "description"
    t.datetime "datetime"
    t.datetime "last_modified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "event_avatar"
    t.bigint "user_id", default: 1
    t.string "external_event_id"
    t.string "event_box_office"
    t.string "ticket_source"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "guests", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "affiliation"
    t.string "category"
    t.integer "alloted_seats"
    t.integer "commited_seats"
    t.integer "guest_commited"
    t.boolean "status"
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "rsvp_link"
    t.string "section"
    t.index ["event_id"], name: "index_guests_on_event_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.string "scopes"
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "referrals", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "guest_id"
    t.string "email", null: false
    t.string "name", null: false
    t.string "referred", null: false
    t.string "status", default: "f"
    t.integer "tickets", default: 0
    t.float "amount", default: 0.0
    t.string "reward_method", default: "reward/ticket"
    t.float "reward_input", default: 0.0
    t.float "reward_value", default: 0.0
    t.integer "ref_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_referrals_on_event_id"
    t.index ["guest_id"], name: "index_referrals_on_guest_id"
  end

  create_table "seats", force: :cascade do |t|
    t.string "category"
    t.integer "total_count"
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "section"
    t.index ["event_id"], name: "index_seats_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "eventbrite_uid"
    t.string "eventbrite_token"
    t.string "encrypted_password", default: "", null: false
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "email_services", "events"
  add_foreign_key "email_services", "guests"
  add_foreign_key "events", "users"
  add_foreign_key "guests", "events"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "seats", "events"
end
