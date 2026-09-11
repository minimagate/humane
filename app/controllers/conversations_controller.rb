class ConversationsController < ApplicationController
  before_action :set_agent

  def show
    @conversation = @agent.conversations.find(params[:id])
    @messages = @conversation.messages.order(:created_at)
    @message = Message.new
  end

  private

  def set_agent
    @agent = Agent.find(params[:agent_id])
  end
end
