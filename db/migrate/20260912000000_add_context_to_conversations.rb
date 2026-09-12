class AddContextToConversations < ActiveRecord::Migration[8.1]
  def change
    add_column :conversations, :topic, :text, null: false, default: ""
    add_column :conversations, :summary, :text, null: false, default: ""
    add_column :conversations, :last_active_at, :datetime
    add_column :conversations, :context_started_at, :datetime
    add_column :conversations, :context_version, :integer, null: false, default: 1
  end
end
