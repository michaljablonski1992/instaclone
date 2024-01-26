class AddIsStoryToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :is_story, :boolean, null: false, default: false
  end
end
