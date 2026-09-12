require "test_helper"

class Pi::ContextTest < ActiveSupport::TestCase
  test "uses bounded context without the pending assistant placeholder" do
    agent = Agent.create!(name: "Ada", role: "Researcher", system_prompt: "Be concise.")
    conversation = agent.conversations.create!(topic: "Agent memory", summary: "The team is discussing durable memory.")
    conversation.messages.create!(role: :user, content: "What did we decide before?")
    conversation.messages.create!(role: :assistant, content: "We agreed to store per-agent memories.")
    conversation.update!(context_started_at: Time.current)
    agent.memories.create!(kind: "decision", content: "Use per-agent memories with source messages.", priority: 5, confidence: 0.95)
    conversation.messages.create!(role: :user, content: "How should a memory be selected?")
    pending_reply = conversation.messages.create!(role: :assistant, content: "…")

    prompt = Pi::Context.new(pending_reply).prompt

    assert_includes prompt, "Relevant long-term memory"
    assert_includes prompt, "Earlier conversation excerpts"
    assert_includes prompt, "How should a memory be selected?"
    assert_not_includes prompt, "assistant: …"
    assert_includes Pi::Context.new(pending_reply).system_context, "Humane conversation reference"
  end
end
