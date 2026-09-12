class Conversation < ApplicationRecord
  IDLE_CONTEXT_PERIOD = 30.minutes

  belongs_to :agent
  has_many :messages, dependent: :destroy

  validates :context_version, numericality: { only_integer: true, greater_than: 0 }
  validates :topic, length: { maximum: 500 }
  validates :summary, length: { maximum: 4_000 }

  def start_context_if_idle!(at: Time.current)
    with_lock do
      starts_new_context = last_active_at.nil? || last_active_at <= at - IDLE_CONTEXT_PERIOD

      self.context_version += 1 if starts_new_context && last_active_at.present?
      self.context_started_at = at if starts_new_context
      self.last_active_at = at
      save!

      starts_new_context
    end
  end

  def update_context!(topic:, summary:)
    update!(topic: topic.to_s.strip.truncate(500), summary: summary.to_s.strip.truncate(4_000))
  end

  def pi_session_directory
    agent.runtime_directory.join("pi-sessions", id.to_s, context_version.to_s)
  end
end
