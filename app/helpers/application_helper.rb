module ApplicationHelper
  def flash_class(name)
    case name
    when 'alert', 'error' then 'danger'
    when 'notice' then 'info'
    when 'warning' then 'warning'
    else 'info'
    end
  end

  def user_pp
    (current_user && current_user.profile_pic.attached?) ? current_user.profile_pic : 'user-pp.png'
  end
end
