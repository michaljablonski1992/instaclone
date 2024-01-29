module DomIdsHelper
	include ActionView::RecordIdentifier

	### POSTS
  def post_id(post, prfx = nil)
		prfx = "#{prfx}_show" if @show_modal
		dom_id(post, prfx)
  end
  def post_imgs_id(post)
		post_id(post, 'images')
  end
  def post_actions_id(post)
		post_id(post, 'actions')
  end
	def post_comments_id(post)
		post_id(post, 'comments')
	end
	def post_comments_modal_content_id(post)
		post_id(post, 'comments_modal_content')
	end
	def post_comments_modal_label_id(post)
		post_id(post, 'post_comments_modal_label')
	end
	def post_comments_modal_id(post)
		post_id(post, 'post_comments_modal')
	end
	def post_likes_modal_id(post)
		post_id(post, 'post_likes_modal')
	end
	def post_likes_modal_label_id(post)
		post_id(post, 'post_likes_modal_label')
	end

	### USERS
	def user_id(user, prfx = nil)
		dom_id(user, prfx)
	end

	def liker_id(user)
		user_id(user, 'liker')
	end

	def suggestion_id(user)
		user_id(user, 'suggestion')
	end

	def profile_header_id(user)
		user_id(user, 'profile_header')
	end


	### PARTIALS / locals
	def partial_data_from_content_id(content_id)
		case
		when content_id.include?('liker') then { partial: 'posts/liker', locals: { liker: @user } }
		when content_id.include?('suggestion') then { partial: 'suggestions/suggestion', locals: { suggestion: @user } }
		when content_id.include?('profile_header') then { partial: 'users/profile_header', locals: { user: @user } }
		else {}
		end
	end
end
