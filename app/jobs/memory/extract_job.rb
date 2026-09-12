class Memory::ExtractJob < ApplicationJob
  queue_as :default

  retry_on Memory::Extractor::Error, wait: 30.seconds, attempts: 3

  def perform(message)
    return unless message.assistant?
    return if message.memory_extracted_at.present?

    result = Memory::Extractor.new(message).call

    message.with_lock do
      return if message.memory_extracted_at.present?

      Memory::Extraction.new(agent: message.conversation.agent, conversation: message.conversation, source_message: message, result: result).apply!
      message.update!(memory_extracted_at: Time.current)
    end
  end
end
