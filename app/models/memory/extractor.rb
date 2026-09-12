require "open3"
require "timeout"

class Memory::Extractor
  class Error < StandardError; end

  def initialize(message)
    @message = message
  end

  def call
    stdout, status = Timeout.timeout(60) do
      Open3.capture2e({ "OPENAI_API_KEY" => api_key }, "node", Rails.root.join("script", "memory_runner.mjs").to_s, stdin_data: payload.to_json)
    end
    raise Error, "Memory extraction failed." unless status.success?

    JSON.parse(stdout)
  rescue Timeout::Error
    raise Error, "Memory extraction timed out."
  rescue JSON::ParserError
    raise Error, "Memory extraction returned invalid data."
  end

  private

  attr_reader :message

  def api_key
    Rails.configuration.x.pi.api_key.presence || raise(Error, "OPENAI_API_KEY is not configured.")
  end

  def payload
    conversation = message.conversation
    {
      model: Rails.configuration.x.pi.model,
      memories: conversation.agent.memories.active.limit(50).map { |memory| memory.slice(:id, :kind, :content, :priority, :confidence) },
      messages: conversation.messages.where("created_at <= ?", message.created_at).where.not(id: message.id).order(:created_at).last(12).map { |entry| entry.slice(:role, :content) } + [ message.slice(:role, :content) ]
    }
  end
end
