class Agent < ApplicationRecord
  AVATAR_FILENAMES = (1..10).map { |number| format("avatar-%02d.avif", number) }.freeze

  has_many :conversations, dependent: :destroy

  before_create :assign_random_avatar

  validates :name, :role, :system_prompt, presence: true

  def runtime_directory
    Rails.root.join("storage", "agents", id.to_s)
  end

  def write_runtime_files!
    FileUtils.mkdir_p(runtime_directory.join(".agents", "skills"))
    File.write(runtime_directory.join("AGENTS.md"), system_prompt)
  end

  def skills
    AgentSkill.all(self)
  end

  private

  def assign_random_avatar
    self.avatar = AVATAR_FILENAMES.sample
  end
end
