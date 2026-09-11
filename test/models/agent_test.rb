require "test_helper"

class AgentTest < ActiveSupport::TestCase
  test "requires a name, role, and system prompt" do
    agent = Agent.new

    assert_not agent.valid?
    assert_includes agent.errors.attribute_names, :name
    assert_includes agent.errors.attribute_names, :role
    assert_includes agent.errors.attribute_names, :system_prompt
  end

  test "assigns a random avatar from the bundled library" do
    agent = Agent.create!(name: "Ada", role: "Researcher", system_prompt: "Be concise.")

    assert_includes Agent::AVATAR_FILENAMES, agent.avatar
  end
end
