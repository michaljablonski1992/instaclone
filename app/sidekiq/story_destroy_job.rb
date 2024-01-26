class StoryDestroyJob
  include Sidekiq::Job

  def perform(story_id)
    story = Post.stories.find(story_id)
    story.destroy!
  end
end
