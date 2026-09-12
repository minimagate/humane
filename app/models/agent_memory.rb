class AgentMemory < ApplicationRecord
  KINDS = %w[fact preference project relationship decision].freeze
  STATUSES = %w[active archived superseded].freeze

  belongs_to :agent
  belongs_to :source_message, class_name: "Message", optional: true

  validates :content, presence: true, length: { maximum: 2_000 }
  validates :kind, inclusion: { in: KINDS }
  validates :priority, inclusion: { in: 1..5 }
  validates :confidence, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "active") }
  scope :usable_at, ->(time) { active.where("expires_at IS NULL OR expires_at > ?", time) }

  def self.for_context(agent, query, limit: 8, at: Time.current)
    memories = usable_at(at).where(agent: agent).to_a
    selected = memories.sort_by { |memory| -memory.context_score(query, at:) }.first(limit)
    where(id: selected.map(&:id)).update_all(last_used_at: at) if selected.any?
    selected
  end

  def context_score(query, at: Time.current)
    words = query.to_s.downcase.scan(/[[:alnum:]]{3,}/).uniq
    matches = words.count { |word| content.downcase.include?(word) }
    freshness = updated_at >= 30.days.ago ? 1 : 0

    (priority * 3) + (confidence * 5) + (matches * 4) + freshness
  end
end
