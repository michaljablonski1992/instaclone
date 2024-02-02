class Post < ApplicationRecord
  STORY_TIME = 24.hours
  MAX_CAPTION_LENGTH = 3_000


  scope :stories, -> { where(is_story: true) }

  belongs_to :user

  has_many_attached :images, dependent: :destroy
  validates :images, presence: true, blob: { content_type: :image, size_range: 1..(10.megabytes) }

  validates :caption, presence: true, length: { maximum: MAX_CAPTION_LENGTH }

  has_many :likes, dependent: :destroy
  has_many :likers, through: :likes, source: :user

  has_many :comments, dependent: :destroy

  after_create :set_story_job, if: :is_story?

  def liked_by_user?(_user)
    likes.find_by(user: _user).present?
  end

  def location_provided?
    longitude.present? && latitude.present?
  end

  private

  def set_story_job
    StoryDestroyJob.perform_in(STORY_TIME, id)
  end
end
