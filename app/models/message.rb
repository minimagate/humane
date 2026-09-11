class Message < ApplicationRecord
  belongs_to :conversation

  enum :role, { user: "user", assistant: "assistant" }, validate: true

  validates :content, presence: true

  after_create_commit -> { broadcast_append_to conversation, target: "messages", partial: "conversations/message", locals: { message: self } }
  after_update_commit -> { broadcast_replace_to conversation, target: dom_id, partial: "conversations/message", locals: { message: self } }
end
