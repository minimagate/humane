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

ActiveRecord::Schema[8.1].define(version: 2026_09_12_000200) do
  create_table "agent_memories", force: :cascade do |t|
    t.integer "agent_id", null: false
    t.float "confidence", default: 0.5, null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "kind", null: false
    t.datetime "last_used_at"
    t.integer "priority", default: 3, null: false
    t.integer "source_message_id"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "status", "priority"], name: "index_agent_memories_for_context"
    t.index ["agent_id"], name: "index_agent_memories_on_agent_id"
    t.index ["source_message_id"], name: "index_agent_memories_on_source_message_id"
  end

  create_table "agents", force: :cascade do |t|
    t.string "avatar", default: "avatar-01.avif", null: false
    t.datetime "created_at", null: false
    t.text "description", default: "", null: false
    t.string "name", null: false
    t.string "role", null: false
    t.text "system_prompt", null: false
    t.datetime "updated_at", null: false
  end

  create_table "conversations", force: :cascade do |t|
    t.integer "agent_id", null: false
    t.datetime "context_started_at"
    t.integer "context_version", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "last_active_at"
    t.text "summary", default: "", null: false
    t.text "topic", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_conversations_on_agent_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content", null: false
    t.integer "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "memory_extracted_at"
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  add_foreign_key "agent_memories", "agents"
  add_foreign_key "agent_memories", "messages", column: "source_message_id"
  add_foreign_key "conversations", "agents"
  add_foreign_key "messages", "conversations"
end
