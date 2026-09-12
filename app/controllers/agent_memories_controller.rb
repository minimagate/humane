class AgentMemoriesController < ApplicationController
  before_action :set_agent

  def index
    @memories = @agent.memories.order(status: :asc, priority: :desc, updated_at: :desc)
  end

  def destroy
    @agent.memories.find(params[:id]).destroy!
    redirect_to agent_memories_path(@agent), notice: "Memory forgotten."
  end

  private

  def set_agent
    @agent = Agent.find(params[:agent_id])
  end
end
