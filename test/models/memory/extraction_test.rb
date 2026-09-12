require "test_helper"

class Memory::ExtractionTest < ActiveSupport::TestCase
  test "creates memories and updates the conversation context from a structured result" do
    agent = Agent.create!(name: "Ada", role: "Researcher", system_prompt: "Be concise.")
    conversation = agent.conversations.create!
    source_message = conversation.messages.create!(role: :assistant, content: "I'll remember that.")

    Memory::Extraction.new(
      agent: agent,
      conversation: conversation,
      source_message: source_message,
      result: {
        "conversation" => { "topic" => "Preferences", "summary" => "The user prefers concise answers." },
        "memories" => [ { "operation" => "create", "kind" => "preference", "content" => "The user prefers concise answers.", "priority" => 4, "confidence" => 0.9 } ]
      }
    ).apply!

    memory = agent.memories.sole
    assert_equal "The user prefers concise answers.", memory.content
    assert_equal source_message, memory.source_message
    assert_equal "Preferences", conversation.reload.topic
  end
end
