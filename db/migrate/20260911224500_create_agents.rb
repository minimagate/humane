class CreateAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :agents do |t|
      t.string :name, null: false
      t.string :role, null: false
      t.text :description, null: false, default: ""
      t.text :system_prompt, null: false

      t.timestamps
    end
  end
end
