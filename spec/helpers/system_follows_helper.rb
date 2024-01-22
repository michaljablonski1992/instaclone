module SystemFollowsHelper

  def test_follow(_within = 'body')
    within _within do
      # assert no unfollow btn visible, do follow, btn follow changed to unfollow
      assert_no_css('.unfollow-btn')
      find('.follow-btn').click
      wait_for_turbo
      assert_no_css('.follow-btn')
      assert_css('.unfollow-btn')
    end
  end

  def test_follow_private(_within = 'body')
    within _within do
      # assert no cancel btn visible, do follow, btn follow changed to cancel
      assert_no_css('.cancel-request-btn')
      find('.follow-btn').click
      wait_for_turbo
      assert_no_css('.follow-btn')
      assert_css('.cancel-request-btn')
    end
  end

  def test_unfollow(_within = 'body')
    within _within do
      # assert no follow btn visible, do unfollow, btn unfollow changed to follow
      assert_no_css('.follow-btn')
      find('.unfollow-btn').click
      wait_for_turbo
      assert_no_css('.unfollow-btn')
      assert_css('.follow-btn')
    end
  end

  def test_cancel_follow_request(_within = 'body')
    within _within do
      # assert no cancel btn visible, do cancel, btn cancel changed to follow
      assert_no_css('.follow-btn')
      find('.cancel-request-btn').click
      wait_for_turbo
      assert_no_css('.cancel-request-btn')
      assert_css('.follow-btn')
    end
  end

end