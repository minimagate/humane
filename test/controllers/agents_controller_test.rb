require "test_helper"

class AgentsControllerTest < ActionDispatch::IntegrationTest
  test "creates an agent" do
    assert_difference "Agent.count" do
      post agents_path, params: { agent: { name: "Ada", role: "Researcher", description: "Finds answers", system_prompt: "Be concise." } }
    end

    assert_redirected_to agent_conversation_path(Agent.last, Agent.last.conversations.first)
    assert_equal "Be concise.", File.read(Agent.last.runtime_directory.join("AGENTS.md"))
  end
end
