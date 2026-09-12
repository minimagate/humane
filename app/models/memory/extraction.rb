class Memory::Extraction
  def initialize(agent:, conversation:, source_message:, result:)
    @agent = agent
    @conversation = conversation
    @source_message = source_message
    @result = result
  end

  def apply!
    apply_conversation_context!
    Array(result["memories"]).each { |proposal| apply_memory!(proposal) }
  end

  private

  attr_reader :agent, :conversation, :source_message, :result

  def apply_conversation_context!
    context = result["conversation"]
    return unless context.is_a?(Hash)

    conversation.update_context!(topic: context["topic"], summary: context["summary"])
  end

  def apply_memory!(proposal)
    return unless proposal.is_a?(Hash)

    case proposal["operation"]
    when "create"
      agent.memories.create!(memory_attributes(proposal))
    when "update"
      find_memory(proposal)&.update!(memory_attributes(proposal))
    when "archive"
      find_memory(proposal)&.update!(status: "archived")
    end
  end

  def find_memory(proposal)
    agent.memories.find_by(id: proposal["memory_id"])
  end

  def memory_attributes(proposal)
    {
      kind: proposal["kind"],
      content: proposal["content"].to_s.strip,
      priority: proposal["priority"],
      confidence: proposal["confidence"],
      source_message: source_message
    }
  end
end
