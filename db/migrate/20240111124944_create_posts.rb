class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.text :caption, null: false
      t.float :longitude, null: false
      t.float :latitude, null: false
      t.references :user, null: false, foreign_key: true
      t.boolean :allow_comments, null: false, default: false
      t.boolean :show_likes_count, null: false, default: false

      t.timestamps
    end
  end
end
