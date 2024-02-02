class ImagesController < ApplicationController
  def image
    @img_url = params[:url] || ''
    @img_id = params[:id] || ''
    @img_class = params[:klass] || ''
    render partial: 'common/lazy_img_content'
  end
end
