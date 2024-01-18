module ApplicationHelper
  def flash_class(name)
    case name
    when 'alert', 'error' then 'danger'
    when 'notice' then 'info'
    when 'warning' then 'warning'
    else 'info'
    end
  end
end
