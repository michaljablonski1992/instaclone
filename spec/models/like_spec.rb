require 'rails_helper'

RSpec.describe Like, :type => :model do
  subject { create(:like) }

  context 'validation' do
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is not valid without a user' do
      subject.user = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid without a post' do
      subject.post = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid with already liked post by user' do
      like2 = subject.dup
      expect(like2).to_not be_valid
    end
  end
end