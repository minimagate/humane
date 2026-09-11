require "yaml"

class AgentSkill
  include ActiveModel::Model
  include ActiveModel::Attributes

  NAME_FORMAT = /\A[a-z0-9][a-z0-9-]{0,62}\z/

  attribute :name, :string
  attribute :description, :string
  attribute :instructions, :string
  attr_reader :agent

  validates :name, format: { with: NAME_FORMAT }
  validates :description, :instructions, presence: true

  def initialize(agent:, **attributes)
    @agent = agent
    super(attributes)
  end

  def self.all(agent)
    Dir.glob(agent.runtime_directory.join(".agents", "skills", "*", "SKILL.md")).filter_map { |path| from_path(agent, path) }.sort_by(&:name)
  end

  def self.find(agent, name)
    skill = all(agent).find { |candidate| candidate.name == name }
    skill || raise(ActiveRecord::RecordNotFound)
  end

  def self.from_path(agent, path)
    frontmatter, instructions = File.read(path).split(/^---\s*$/, 3).drop(1)
    metadata = YAML.safe_load(frontmatter, permitted_classes: [], aliases: false)
    return unless metadata.is_a?(Hash)

    new(agent: agent, name: metadata["name"], description: metadata["description"], instructions: instructions&.strip)
  rescue Psych::Exception
    nil
  end

  def persisted?
    File.exist?(file_path)
  end

  def save
    return false unless valid?

    FileUtils.mkdir_p(file_path.dirname)
    File.write(file_path, serialized_content)
    true
  end

  def update(attributes)
    assign_attributes(attributes)
    save
  end

  private

  def file_path
    agent.runtime_directory.join(".agents", "skills", name.to_s, "SKILL.md")
  end

  def serialized_content
    "---\nname: #{name}\ndescription: #{description.to_json}\n---\n\n#{instructions.rstrip}\n"
  end
end
