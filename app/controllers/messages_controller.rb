class MessagesController < ApplicationController
  before_action :set_agent_and_conversation

  def create
    @message = @conversation.messages.new(message_params.merge(role: :user))

    if @message.save
      @conversation.start_context_if_idle!(at: @message.created_at)
      assistant_message = @conversation.messages.create!(role: :assistant, content: "…")
      Pi::ReplyJob.perform_later(assistant_message)
      redirect_to agent_conversation_path(@agent, @conversation)
    else
      @messages = @conversation.messages.order(:created_at)
      render "conversations/show", status: :unprocessable_entity
    end
  end

  private

  def set_agent_and_conversation
    @agent = Agent.find(params[:agent_id])
    @conversation = @agent.conversations.find(params[:conversation_id])
  end

  def message_params
    params.expect(message: [ :content ])
  end
end
