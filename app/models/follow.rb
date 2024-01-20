class Follow < ApplicationRecord
  before_create :check_privacy
  belongs_to :follower, class_name: 'User', foreign_key: 'follower_id'
  belongs_to :followed, class_name: 'User', foreign_key: 'followed_id'

  # already followed
  validates :follower, uniqueness: { scope: :followed }

  # cannot follow himself
  validate :follow_himself?

  def accept!
    self.update(accepted: true)
  end

  private

  def check_privacy
    self.accepted = true unless self.followed.private?
  end

  def follow_himself?
    errors.add :followed, I18n.t('follow.errors.follows_himself')  if follower == followed
  end

end