class AgentSkillsController < ApplicationController
  before_action :set_agent
  before_action :set_skill, only: [ :edit, :update ]

  def index
    @skills = @agent.skills
  end

  def new
    @skill = AgentSkill.new(agent: @agent, instructions: "# Instructions\n\n")
  end

  def create
    @skill = AgentSkill.new(agent: @agent, **skill_params)

    if @skill.save
      redirect_to agent_skills_path(@agent), notice: "Skill created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @skill.update(skill_params.except(:name))
      redirect_to agent_skills_path(@agent), notice: "Skill saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_agent
    @agent = Agent.find(params[:agent_id])
  end

  def set_skill
    @skill = AgentSkill.find(@agent, params[:id])
  end

  def skill_params
    params.expect(agent_skill: [ :name, :description, :instructions ])
  end
end
