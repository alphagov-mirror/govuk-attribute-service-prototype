# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_01_26_125230) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "claims", primary_key: ["subject_identifier", "claim_identifier"], force: :cascade do |t|
    t.string "subject_identifier", null: false
    t.uuid "claim_identifier", null: false
    t.jsonb "claim_value"
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.index ["claim_identifier"], name: "index_claims_on_claim_identifier"
    t.index ["subject_identifier"], name: "index_claims_on_subject_identifier"
  end

end
