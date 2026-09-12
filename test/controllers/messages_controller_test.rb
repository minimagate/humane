require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  test "persists a user message" do
    agent = Agent.create!(name: "Ada", role: "Researcher", system_prompt: "Be concise.")
    conversation = agent.conversations.create!

    assert_difference "Message.count", 2 do
      assert_enqueued_with(job: Pi::ReplyJob) do
        post agent_conversation_messages_path(agent, conversation), params: { message: { content: "Find a source." } }
      end
    end

    assert_equal "assistant", Message.last.role
    assert_not_nil conversation.reload.context_started_at
    assert_not_nil conversation.last_active_at
    assert_redirected_to agent_conversation_path(agent, conversation)
  end

  test "rejects a blank message" do
    agent = Agent.create!(name: "Ada", role: "Researcher", system_prompt: "Be concise.")
    conversation = agent.conversations.create!

    assert_no_difference "Message.count" do
      post agent_conversation_messages_path(agent, conversation), params: { message: { content: "" } }
    end

    assert_response :unprocessable_entity
  end
end
