class Conversation < ApplicationRecord
  belongs_to :agent
  has_many :messages, dependent: :destroy
end
