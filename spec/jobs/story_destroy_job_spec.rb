require 'rails_helper'

RSpec.describe StoryDestroyJob, type: :job do
  subject { StoryDestroyJob }

  context 'story' do
    it "doesn't create StoryDestroyJob when not story" do
      expect { create(:post) }.to_not enqueue_sidekiq_job(subject)
    end
    
    it 'creates StoryDestroyJob when story' do
      expect { create(:story) }.to enqueue_sidekiq_job(subject)
    end

    it 'creates StoryDestroyJob when story with delay' do
      freeze_time do
        expect { create(:story) }.to enqueue_sidekiq_job(subject).in(Post::STORY_TIME)
      end
    end
  end
end