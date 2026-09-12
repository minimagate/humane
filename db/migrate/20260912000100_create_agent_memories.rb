class CreateAgentMemories < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_memories do |t|
      t.references :agent, null: false, foreign_key: true
      t.references :source_message, foreign_key: { to_table: :messages }
      t.string :kind, null: false
      t.text :content, null: false
      t.integer :priority, null: false, default: 3
      t.float :confidence, null: false, default: 0.5
      t.string :status, null: false, default: "active"
      t.datetime :expires_at
      t.datetime :last_used_at

      t.timestamps
    end

    add_index :agent_memories, [ :agent_id, :status, :priority ], name: "index_agent_memories_for_context"
  end
end
