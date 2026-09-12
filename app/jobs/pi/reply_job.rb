class Pi::ReplyJob < ApplicationJob
  queue_as :default

  def perform(message)
    reply = +""
    Pi::Reply.new(message).stream do |delta|
      reply << delta
      message.update!(content: reply)
    end
    Memory::ExtractJob.perform_later(message)
  rescue Pi::Reply::Error
    message.update!(content: "I couldn't complete that reply. Please try again.")
  end
end
