class ChangePostsLongitudeAndLatitude < ActiveRecord::Migration[7.1]
  def up
    change_column :posts, :longitude, :decimal, null: true, precision: 10, scale: 6
    change_column :posts, :latitude, :decimal, null: true, precision: 10, scale: 6
  end

  def down
    change_column :posts, :longitude, :float, null: false
    change_column :posts, :latitude, :float, null: false
  end
end
