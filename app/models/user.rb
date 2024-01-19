class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

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
  validates :profile_pic, blob: { content_type: :image } 

  has_many :likes, dependent: :destroy

  has_many :comments, dependent: :destroy

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true, format: { with: /^[a-zA-Z0-9_\.]*$/, multiline: true }

  def profile_picture
    (profile_pic.attached? && profile_pic.blob.present? && profile_pic.blob.persisted?) ? profile_pic : 'user-pp.png'
  end
end
