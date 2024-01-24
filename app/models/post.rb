class Post < ApplicationRecord
  belongs_to :user

  has_many_attached :images, dependent: :destroy
  validates :images, presence: true, blob: { content_type: :image } 

  validates :caption, presence: true

  has_many :likes, dependent: :destroy
  has_many :likers, through: :likes, source: :user

  has_many :comments, dependent: :destroy

  def liked_by_user?(_user)
    likes.find_by(user: _user)
  end

  def location_provided?
    longitude.present? && latitude.present?
  end
end
