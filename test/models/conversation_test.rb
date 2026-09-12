require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  test "starts a new context after thirty idle minutes" do
    conversation = Agent.create!(name: "Ada", role: "Researcher", system_prompt: "Be concise.").conversations.create!

    travel_to Time.zone.parse("2026-09-12 09:00") do
      assert_predicate conversation.start_context_if_idle!, :itself
      assert_not conversation.start_context_if_idle!(at: 29.minutes.from_now)
      assert_predicate conversation.start_context_if_idle!(at: 60.minutes.from_now), :itself
    end

    assert_equal 2, conversation.reload.context_version
    assert_equal Rails.root.join("storage", "agents", conversation.agent_id.to_s, "pi-sessions", conversation.id.to_s, "2"), conversation.pi_session_directory
  end
end
