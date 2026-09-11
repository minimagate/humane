require "test_helper"

class AgentSkillTest < ActiveSupport::TestCase
  test "writes a Pi-compatible skill file" do
    agent = Agent.create!(name: "Ada", role: "Researcher", system_prompt: "Be concise.")
    skill = AgentSkill.new(agent: agent, name: "web-research", description: "Researches the web", instructions: "# Web research")

    assert skill.save
    assert_equal "web-research", AgentSkill.find(agent, "web-research").name
    assert_includes File.read(agent.runtime_directory.join(".agents", "skills", "web-research", "SKILL.md")), "description: \"Researches the web\""
  end
end
