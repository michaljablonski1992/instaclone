require 'rails_helper'

RSpec.describe Post, :type => :model do
  subject { create(:post) }

  context 'validation' do
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is not valid without a user' do
      subject.user = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid without a image' do
      subject.images = []
      expect(subject).to_not be_valid
    end

    it 'is not valid without a caption' do
      subject.caption = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid when caption is too long' do
      subject.caption = 'x' * (Post::MAX_CAPTION_LENGTH + 1)
      expect(subject).to_not be_valid
    end
  end

  context 'liked_by_user?' do
    it 'returns false if not liked by user' do
      user = create(:user)
      expect(subject.liked_by_user?(user)).to be false
    end
    it 'returns true if liked by user' do
      user = create(:user)
      like = create(:like, user: user, post: subject)
      expect(subject.liked_by_user?(user)).to be true
    end
  end

  context 'location_provided?' do
    it 'returns false if neither longitude nor latitude provided' do
      expect(subject.location_provided?).to be false
    end
    it 'returns false if longitude not provided' do
      subject.latitude = 1.5
      expect(subject.location_provided?).to be false
    end
    it 'returns false if latitude not provided' do
      subject.longitude = 1.5
      expect(subject.location_provided?).to be false
    end
    it 'returns true if latitude and longitude provided' do
      subject.longitude = 1.5
      subject.latitude = 1.5
      expect(subject.location_provided?).to be true
    end
  end
end