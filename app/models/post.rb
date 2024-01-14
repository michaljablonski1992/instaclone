class Post < ApplicationRecord
  belongs_to :user

  has_many_attached :images
  validates :images, presence: true, blob: { content_type: :image } 

  validates :caption, presence: true
  validates :longitude, presence: true
  validates :latitude, presence: true

  has_many :likes
  has_many :likers, through: :likes, source: :user

  ## TODO: DELETE ME after location implentation
  after_initialize :mock_location
  def mock_location
    self.latitude = 22.22
    self.longitude = 22.22
  end

  def liked_by_user?(_user)
    likes.find_by(user: _user)
  end
end
