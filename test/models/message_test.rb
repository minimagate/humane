require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "requires content" do
    assert_not Message.new(role: :user).valid?
  end
end
