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

ActiveRecord::Schema[7.1].define(version: 2024_06_22_205152) do
  create_table "books", force: :cascade do |t|
    t.string "title", null: false
    t.string "author", null: false
    t.string "genre", null: false
    t.string "isbn", null: false
    t.integer "total_copies", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
  end

# Could not dump table "books_search_idx" because of following StandardError
#   Unknown type '' for column 'title'

# Could not dump table "books_search_idx_config" because of following StandardError
#   Unknown type '' for column 'k'

  create_table "books_search_idx_data", force: :cascade do |t|
    t.binary "block"
  end

  create_table "books_search_idx_docsize", force: :cascade do |t|
    t.binary "sz"
    t.integer "origin"
  end

# Could not dump table "books_search_idx_idx" because of following StandardError
#   Unknown type '' for column 'segid'

# Could not dump table "books_search_idx_instance" because of following StandardError
#   Unknown type '' for column 'term'

# Could not dump table "books_search_idx_row" because of following StandardError
#   Unknown type '' for column 'term'

  create_table "genres", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_genres_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "librarian", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
