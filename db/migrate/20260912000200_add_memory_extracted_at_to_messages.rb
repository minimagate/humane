class AddMemoryExtractedAtToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :memory_extracted_at, :datetime
  end
end
