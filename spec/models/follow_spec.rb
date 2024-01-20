require 'rails_helper'

RSpec.describe Follow, :type => :model do
  subject { create(:follow) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is invalid without follower' do
    subject.follower = nil
    expect(subject).to_not be_valid
  end

  it 'is invalid without followed' do
    subject.followed = nil
    expect(subject).to_not be_valid
  end

  it "is invalid for the same follower<->followed relation - 'already followed'" do
    follow2 = subject.dup
    expect(follow2).to_not be_valid
  end
  
end