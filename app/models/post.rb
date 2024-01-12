class Post < ApplicationRecord
  belongs_to :user

  has_many_attached :images
  validates :images, presence: true, blob: { content_type: :image } 

  validates :caption, presence: true
  validates :longitude, presence: true
  validates :latitude, presence: true

  ## TODO: DELETE ME after location implentation
  after_initialize :mock_location
  def mock_location
    self.latitude = 22.22
    self.longitude = 22.22
  end
end
