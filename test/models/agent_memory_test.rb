require "test_helper"

class AgentMemoryTest < ActiveSupport::TestCase
  test "selects active relevant memories and records their use" do
    agent = Agent.create!(name: "Ada", role: "Researcher", system_prompt: "Be concise.")
    relevant = agent.memories.create!(kind: "project", content: "Humane uses Rails and Pi.", priority: 3, confidence: 0.9)
    agent.memories.create!(kind: "fact", content: "The user's favorite color is blue.", priority: 1, confidence: 0.8)
    agent.memories.create!(kind: "fact", content: "Old note.", priority: 5, confidence: 1, status: "archived")

    memories = AgentMemory.for_context(agent, "How does the Humane Rails app use Pi?", limit: 1)

    assert_equal [ relevant ], memories
    assert_not_nil relevant.reload.last_used_at
  end
end
