## get rid of field_error_proc wrapper
module CustomFormFor
  def custom_form_for(*args, &block)
    original_field_error_proc = ::ActionView::Base.field_error_proc
    ::ActionView::Base.field_error_proc = -> (html_tag, instance) { html_tag }
    form_for(*args, &block)
  ensure
    ::ActionView::Base.field_error_proc = original_field_error_proc
  end
end