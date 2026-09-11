require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  test "shows a conversation" do
    agent = Agent.create!(name: "Ada", role: "Researcher", system_prompt: "Be concise.")
    conversation = agent.conversations.create!

    get agent_conversation_path(agent, conversation)

    assert_response :success
  end
end
