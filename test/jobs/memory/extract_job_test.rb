require "test_helper"

class Memory::ExtractJobTest < ActiveJob::TestCase
  test "marks an assistant message after applying extraction" do
    agent = Agent.create!(name: "Ada", role: "Researcher", system_prompt: "Be concise.")
    message = agent.conversations.create!.messages.create!(role: :assistant, content: "Done.")
    extractor = Object.new
    extractor.define_singleton_method(:call) do
      { "conversation" => { "topic" => "", "summary" => "" }, "memories" => [] }
    end

    original_new = Memory::Extractor.method(:new)
    Memory::Extractor.singleton_class.define_method(:new) { |_message| extractor }
    Memory::ExtractJob.perform_now(message)

    assert_not_nil message.reload.memory_extracted_at
  ensure
    Memory::Extractor.singleton_class.define_method(:new, original_new) if original_new
  end
end
