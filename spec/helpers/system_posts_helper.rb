module SystemPostsHelper

  def within_first_post(&block)
    within '#posts-list' do
      within first('.post-cnt') do
        yield
      end
    end
  end
  
end