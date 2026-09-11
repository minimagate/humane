class AgentsController < ApplicationController
  before_action :set_agent, only: [ :edit, :update ]

  def index
    @agents = Agent.order(:name)
    @agent = Agent.new(system_prompt: default_system_prompt)
  end

  def new
    @agents = Agent.order(:name)
    @agent = Agent.new(system_prompt: default_system_prompt)
    @show_agent_modal = true
    render :index
  end

  def create
    @agent = Agent.new(agent_params)

    if @agent.valid?
      Agent.transaction do
        @agent.save!
        @conversation = @agent.conversations.create!
      end
      @agent.write_runtime_files!
      redirect_to agent_conversation_path(@agent, @conversation), notice: "Agent created."
    else
      @agents = Agent.order(:name)
      @show_agent_modal = true
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    @agents = Agent.order(:name)
  end

  def update
    if @agent.update(agent_params)
      @agent.write_runtime_files!
      redirect_to edit_agent_path(@agent), notice: "AGENTS.md saved."
    else
      @agents = Agent.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_agent
    @agent = Agent.find(params[:id])
  end

  def agent_params
    params.expect(agent: [ :name, :role, :description, :system_prompt ])
  end

  def default_system_prompt
    "You are a thoughtful AI teammate. Be concise, practical, and clear."
  end
end
