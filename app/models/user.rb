class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts
  has_one_attached :profile_pic

  has_many :likes

  has_many :comments

  validates :full_name, presence: true
  validates :username, presence: true

  def profile_picture
    profile_pic.attached? ? profile_pic : 'user-pp.png'
  end
end
