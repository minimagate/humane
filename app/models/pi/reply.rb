require "open3"
require "timeout"

class Pi::Reply
  class Error < StandardError; end

  def initialize(message)
    @message = message
    @conversation = message.conversation
  end

  def call
    reply = +""
    stream { |delta| reply << delta }
    reply.presence || raise(Error, "Pi returned an empty reply.")
  end

  def stream
    raise Error, "Set OPENAI_API_KEY in .env.local to chat with agents." if api_key.blank?

    received_content = false
    status = Timeout.timeout(180) do
      Open3.popen3({ "OPENAI_API_KEY" => api_key }, "node", Rails.root.join("script", "pi_runner.mjs").to_s) do |stdin, stdout, _stderr, wait_thread|
        stdin.write(payload.to_json)
        stdin.close

        stdout.each_line do |line|
          event = JSON.parse(line)
          next unless event["type"] == "delta"

          received_content = true
          yield event.fetch("content")
        end

        wait_thread.value
      end
    end
    raise Error, "Pi could not complete that reply." unless status.success?
    raise Error, "Pi returned an empty reply." unless received_content
  rescue Timeout::Error
    raise Error, "Pi took too long to reply. Please try again."
  rescue JSON::ParserError, KeyError
    raise Error, "Pi returned an unreadable reply."
  end

  private

  def api_key
    Rails.configuration.x.pi.api_key
  end

  def payload
    {
      agent_directory: @conversation.agent.runtime_directory.to_s,
      computer_directory: @conversation.agent.computer_directory.to_s,
      pi_session_directory: @conversation.pi_session_directory.to_s,
      agent_dir: Rails.root.join("storage", "pi").to_s,
      model: Rails.configuration.x.pi.model,
      bootstrap_prompt: context.prompt,
      continuation_prompt: context.continuation_prompt,
      system_context: context.system_context
    }
  end

  def context
    @context ||= Pi::Context.new(@message)
  end
end
