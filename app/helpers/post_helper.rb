module PostHelper
  def post_id(post)
     "post#{post.id}"
  end
  def post_imgs_id(post)
     "#{post_id(post)}_images"
  end
  def post_actions_id(post)
     "#{post_id(post)}_actions"
  end
end
