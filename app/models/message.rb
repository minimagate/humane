class Message < ApplicationRecord
  belongs_to :conversation
  has_many :sourced_memories, class_name: "AgentMemory", foreign_key: :source_message_id, dependent: :nullify

  enum :role, { user: "user", assistant: "assistant" }, validate: true

  validates :content, presence: true

  after_create_commit -> { broadcast_append_to conversation, target: "messages", partial: "conversations/message", locals: { message: self } }
  after_update_commit -> { broadcast_replace_to conversation, target: ActionView::RecordIdentifier.dom_id(self), partial: "conversations/message", locals: { message: self } }
end
