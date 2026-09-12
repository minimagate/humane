require "test_helper"

class Pi::ReplyTest < ActiveSupport::TestCase
  test "builds a bootstrap and continuation prompt for the conversation epoch" do
    agent = Agent.create!(name: "Ada", role: "Researcher", system_prompt: "Be concise.")
    conversation = agent.conversations.create!(context_started_at: Time.current, topic: "Memory")
    conversation.messages.create!(role: :user, content: "Remember my preference.")
    reply = conversation.messages.create!(role: :assistant, content: "…")

    payload = Pi::Reply.new(reply).send(:payload)

    assert_includes payload[:bootstrap_prompt], "Remember my preference."
    assert_equal "Remember my preference.", payload[:continuation_prompt]
    assert_equal conversation.pi_session_directory.to_s, payload[:pi_session_directory]
  end
end
