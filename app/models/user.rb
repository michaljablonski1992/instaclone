class User < ApplicationRecord
  HOME_PAGE_SUGGESTIONS_COUNT = 5
  SUGGESTIONS_COUNT = 20
  DEF_PP = 'user-pp.png'
  DISCOVERS_COUNT = 32

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, 
         :confirmable, :omniauthable, omniauth_providers: %i[facebook]
  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |u|
      u.email = auth.info.email
      u.password = Devise.friendly_token[0, 20]
      u.full_name = auth.info.name   # assuming the user model has a name
      u.username = u.generate_username
      
      ## not working until app is published on developers.facebook.com
      # downloaded_image = OpenURI.open_uri(auth.info.image)
      # u.profile_pic.attach(io: downloaded_image, filename: "profile_picture.jpg")

      # If you are using confirmable and the provider(s) you use validate emails, 
      # uncomment the line below to skip the confirmation emails.
      u.skip_confirmation!
    end
  end
  # allow user to login using username or email
  attr_accessor :login
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  has_many :posts, dependent: :destroy
  has_one_attached :profile_pic, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  ## follows
  has_many :waiting_sent_requests, -> { where(accepted: false) }, class_name: 'Follow', foreign_key: 'follower_id'
  has_many :follow_requests, -> { where(accepted: false) }, class_name: 'Follow', foreign_key: 'followed_id'
  has_many :accepted_recieved_requests, -> { where(accepted: true) }, class_name: 'Follow', foreign_key: 'followed_id'
  has_many :accepted_sent_requests, -> { where(accepted: true) }, class_name: 'Follow', foreign_key: 'follower_id'
  has_many :followers, through: :accepted_recieved_requests, source: :follower
  has_many :followings, through: :accepted_sent_requests, source: :followed
  has_many :waiting_followings, through: :waiting_sent_requests, source: :followed

  validates :profile_pic, blob: { content_type: :image } 
  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true, format: { with: /^[a-zA-Z0-9_\.]*$/, multiline: true }

  def self.search(q)
    _q = "%#{q.downcase}%"
    User.where("lower(username) LIKE ? or lower(full_name) LIKE ?", _q, _q)
  end

  def profile_picture
    profile_pic_exists? ? profile_pic : DEF_PP
  end

  def can_see_posts?(user)
    !user.private? || user == self || followings.include?(user)
  end

  ## follows
  def follow!(user)
    Follow.create(follower: self, followed: user)
  end
  def unfollow!(user)
    self.accepted_sent_requests.find_by(followed: user)&.destroy
  end
  def cancel_request!(user)
    self.waiting_sent_requests.find_by(followed: user)&.destroy
  end

  ## suggestions
  def suggestions(count = HOME_PAGE_SUGGESTIONS_COUNT)
    suggestions = [followers]
    [followers, followings].flatten.uniq.each do |f|
      suggestions.append([f.followers, f.followings])
    end
    suggestions = suggestions.flatten.uniq
    suggestions = (suggestions - [followings, self].flatten)
    suggestions = suggestions.sample(count)
    if suggestions.blank?
      suggestions = User.where.not(id: [followings, self].flatten).sample(count)
    end
    suggestions
  end

  ## feeds
  def feeds(stories: false)
    Post.where(user: [self, self.followings].flatten, is_story: stories).order(created_at: :desc)
  end

  ## discovers
  def discovers(count = DISCOVERS_COUNT)
    Post.joins(:user)
        .where('users.private IS false')
        .where.not(user: [self, self.followings].flatten)
        .order(created_at: :desc)
  end 

  def profile_pic_exists?
    (profile_pic.attached? && profile_pic.blob.present? && profile_pic.blob.persisted?)
  end

  def generate_username
    # try to be unique
    try_nr = 0
    max_tries = 100
    _username = nil
    loop do
      _username = SecureRandom.hex(8)

      break unless self.class.where(username: _username).present?

      raise "Cannot generate new username. Tried #{try_nr}" if try_nr > max_tries
      try_nr += 1
    end

    _username
  end

  def from_omniauth?
    provider.present?
  end
end
