require 'rails_helper'

RSpec.describe User, :type => :model do
  subject { create(:user) }

  context 'validation' do
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

  context 'follows private user' do
    it 'can follow many users' do
      # create follower and users to follow
      follower = create(:user)
      to_follow = []
      5.times { to_follow << create(:user) }
      to_follow.each {|following| follower.follow!(following) }
  
      # expect follows added
      expect(Follow.count).to eq 5
  
      # expect all users got follow request, not accepted so no followers yet
      to_follow.each do |following|
        expect(following.follow_requests.count).to eq 1
        expect(following.follow_requests.last.follower).to eq follower
        expect(following.followers.count).to eq 0
      end
  
      # expect all follower's requests are not accepted yet
      expect(follower.followings.count).to eq 0
  
      # accept 2 follow requests
      to_follow.take(2).each {|following| following.follow_requests.each(&:accept!)}
  
      # expect follower follows 2 users(2 accepted)
      expect(follower.followings.count).to eq 2
      
      # accept the rest
      to_follow.last(3).each {|following| following.follow_requests.each(&:accept!)}
  
      # expect follower follows 5 users
      expect(follower.followings.count).to eq 5
  
      # expect all users got follow request accepted
      to_follow.each do |following|
        expect(following.follow_requests.count).to eq 0
        expect(following.followers.count).to eq 1
      end
    end

    it 'can be followed by many users' do
      # create user to follow and followers
      to_follow = create(:user)
      followers = []
      5.times { followers << create(:user) }
      followers.each {|user| user.follow!(to_follow) }
  
      # expect follows added
      expect(Follow.count).to eq 5
  
      # expect user got all follow request, not accepted so no followers yet
      expect(to_follow.follow_requests.count).to eq 5
      expect(to_follow.follow_requests.map(&:follower)).to eq followers
      expect(to_follow.followers.count).to eq 0
  
      # expect all follower's requests are not accepted yet
      followers.each { |follower| expect(follower.followings.count).to eq 0 }
  
      # accept 3 follow requests
      to_follow.follow_requests.take(3).each(&:accept!)
  
      # expect 3 follower follow user
      expect(to_follow.followers.count).to eq 3
      
      # accept the rest
      to_follow.follow_requests.last(2).each(&:accept!)
      
      # expect all users requests got accepted
      expect(to_follow.followers.count).to eq 5
      expect(to_follow.follow_requests.count).to eq 0

      # expect all followers follow user
      followers.each do |follower| 
        expect(follower.followings.count).to eq 1
        expect(follower.followings.last).to eq to_follow
      end
    end

    it 'can follow same user only once / user can be followed by the same follower only once' do
      # create follower and user to follow
      follower = create(:user)
      to_follow = create(:user)

      # do follow, expect 1 follow created
      follower.follow!(to_follow)
      expect(Follow.count).to eq 1

      # do follow again, expect no follow created
      follower.follow!(to_follow)
      expect(Follow.count).to eq 1 # still 1
    end

    it 'cannot follow himself / cannot be followed by himself' do
      # create follower and follow himself
      follower = create(:user)
      follower.follow!(follower)
      # expect no follow
      expect(Follow.count).to eq 0
    end

    it 'can unfollow' do
      # create follower and user to follow
      follower = create(:user)
      to_follow = create(:user)

      # do follow, expect 1 follow created
      follower.follow!(to_follow)
      
      # expect follow added, not accepted
      expect(to_follow.follow_requests.count).to eq 1

      # try to unfollow, cannot unfollow if request not accepted(not following yet)
      follower.unfollow!(to_follow)

      # expect follow exists, not unfollowed
      expect(to_follow.follow_requests.count).to eq 1

      # accept follow
      to_follow.follow_requests.each(&:accept!)

      # expect no request, 1 follower, 1 followings
      expect(to_follow.follow_requests.count).to eq 0
      expect(to_follow.followers.count).to eq 1
      expect(follower.followings.count).to eq 1

      # now unfollow
      follower.unfollow!(to_follow)

      # expect unfollowed
      expect(to_follow.follow_requests.count).to eq 0
      expect(to_follow.followers.count).to eq 0
      expect(follower.followings.count).to eq 0
    end

    it 'can decline request' do
      # create follower and user to follow
      follower = create(:user)
      to_follow = create(:user)

      # do follow, expect 1 follow created
      follower.follow!(to_follow)

      # expect no request, 1 follower
      expect(to_follow.follow_requests.count).to eq 1
      expect(to_follow.followers.count).to eq 0
      expect(follower.followings.count).to eq 0
      expect(follower.waiting_followings.count).to eq 1

      # decline request
      to_follow.follow_requests.each(&:decline!)

      # expect no request, to no follows
      expect(to_follow.follow_requests.count).to eq 0
      expect(to_follow.followers.count).to eq 0
      expect(follower.followings.count).to eq 0
      expect(follower.waiting_followings.count).to eq 0
    end

    it 'can cancel request' do
      # create follower and user to follow
      follower = create(:user)
      to_follow = create(:user)

      # do follow, expect 1 follow created
      follower.follow!(to_follow)

      # expect no request, 1 follower
      expect(to_follow.follow_requests.count).to eq 1
      expect(to_follow.followers.count).to eq 0
      expect(follower.followings.count).to eq 0
      expect(follower.waiting_followings.count).to eq 1

      # cancel request
      follower.cancel_request!(to_follow)

      # expect no request, to no follows
      expect(to_follow.follow_requests.count).to eq 0
      expect(to_follow.followers.count).to eq 0
      expect(follower.followings.count).to eq 0
      expect(follower.waiting_followings.count).to eq 0
    end
  end

  context 'follows not private user' do
    it 'can follow without request' do
      # create follower and user to follow
      follower = create(:user)
      to_follow = create(:user, private: false)

      # do follow, expect 1 follow created
      follower.follow!(to_follow)

      # expect no request, 1 follower
      expect(to_follow.follow_requests.count).to eq 0
      expect(to_follow.followers.count).to eq 1
      expect(follower.followings.count).to eq 1
    end
  end
end