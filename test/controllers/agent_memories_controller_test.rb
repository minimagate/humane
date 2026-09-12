require "test_helper"

class AgentMemoriesControllerTest < ActionDispatch::IntegrationTest
  test "forgets an agent memory" do
    agent = Agent.create!(name: "Ada", role: "Researcher", system_prompt: "Be concise.")
    memory = agent.memories.create!(kind: "fact", content: "A fact.", priority: 3, confidence: 0.8)

    assert_difference "AgentMemory.count", -1 do
      delete agent_memory_path(agent, memory)
    end

    assert_redirected_to agent_memories_path(agent)
  end
end
