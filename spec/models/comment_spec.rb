require 'rails_helper'

RSpec.describe Comment, :type => :model do
  subject { create(:comment) }

  context 'validation' do
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is not valid without a body' do
      subject.body = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid without a user' do
      subject.user = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid without a post' do
      subject.post = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid when body is too long' do
      subject.body = 'x' * (Comment::MAX_BODY_LENGTH + 1)
      expect(subject).to_not be_valid
    end
  end
end