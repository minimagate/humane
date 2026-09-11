class AddAvatarToAgents < ActiveRecord::Migration[8.1]
  def change
    add_column :agents, :avatar, :string, null: false, default: "avatar-01.avif"
  end
end
