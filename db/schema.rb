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

ActiveRecord::Schema[7.1].define(version: 2024_05_24_040043) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "follows", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "followed_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genre_connections", force: :cascade do |t|
    t.bigint "title_id"
    t.bigint "genre_id", null: false
    t.integer "list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_genre_connections_on_genre_id"
    t.index ["title_id"], name: "index_genre_connections_on_title_id"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name"
    t.integer "tmdb_id"
    t.string "cover_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "list_items", force: :cascade do |t|
    t.text "comment"
    t.bigint "title_id", null: false
    t.bigint "list_id", null: false
    t.integer "rank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_list_items_on_list_id"
    t.index ["title_id"], name: "index_list_items_on_title_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.text "description"
    t.string "status"
    t.integer "genre_id"
    t.string "cover_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name"
    t.integer "tmdb_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people_titles", force: :cascade do |t|
    t.bigint "title_id", null: false
    t.bigint "person_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_people_titles_on_person_id"
    t.index ["title_id"], name: "index_people_titles_on_title_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "title_id", null: false
    t.integer "rating"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title_id"], name: "index_reviews_on_title_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.integer "watchmode_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo_url"
  end

  create_table "streamings", force: :cascade do |t|
    t.bigint "title_id", null: false
    t.bigint "service_id", null: false
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "streaming_type"
    t.index ["service_id"], name: "index_streamings_on_service_id"
    t.index ["title_id"], name: "index_streamings_on_title_id"
  end

  create_table "titles", force: :cascade do |t|
    t.string "name"
    t.string "media_type"
    t.integer "tmdb_id"
    t.string "imdb_id"
    t.string "poster_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "imdb_rating"
    t.integer "imdb_votes"
    t.integer "start_year"
    t.integer "end_year"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "profile_picture_url"
    t.text "bio"
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "genre_connections", "genres"
  add_foreign_key "genre_connections", "titles"
  add_foreign_key "list_items", "lists"
  add_foreign_key "list_items", "titles"
  add_foreign_key "lists", "users"
  add_foreign_key "people_titles", "people"
  add_foreign_key "people_titles", "titles"
  add_foreign_key "reviews", "titles"
  add_foreign_key "reviews", "users"
  add_foreign_key "streamings", "services"
  add_foreign_key "streamings", "titles"
end
