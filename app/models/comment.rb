class Comment < ApplicationRecord
  MAX_BODY_LENGTH = 1_000
  belongs_to :user
  belongs_to :post

  validates :body, presence: true, length: { maximum: MAX_BODY_LENGTH }
end