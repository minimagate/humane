require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "requires content" do
    assert_not Message.new(role: :user).valid?
  end

  test "updates an assistant message" do
    agent = Agent.create!(name: "Ada", role: "Researcher", system_prompt: "Be concise.")
    message = agent.conversations.create!.messages.create!(role: :assistant, content: "…")

    message.update!(content: "Good morning.")

    assert_equal "Good morning.", message.reload.content
  end
end
