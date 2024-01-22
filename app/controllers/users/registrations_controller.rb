class Users::RegistrationsController < Devise::RegistrationsController

  def update
    @old_picture = resource.profile_picture
    super
  end

  private

  def after_inactive_sign_up_path_for(resource_or_scope)
    new_user_session_path
  end
end
