require 'rails_helper'

RSpec.describe User, :type => :model do
  subject { create(:user) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is valid with valid username' do
    subject.username = 'valid_username123'
    expect(subject).to be_valid
  end

  it 'is not valid without a email' do
    subject.email = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a full_name' do
    subject.full_name = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a username' do
    subject.username = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid with taken email' do
    user2 = create(:user)
    subject.email = user2.email
    expect(subject).to_not be_valid
  end

  it 'is not valid with inavlid email' do
    subject.email = 'not_email'
    expect(subject).to_not be_valid
  end

  it 'is not valid with taken username' do
    user2 = create(:user)
    subject.username = user2.username
    expect(subject).to_not be_valid
  end

  it 'is not valid with invalid username' do
    subject.username = 'abc DEW 123'
    expect(subject).to_not be_valid
  end
end