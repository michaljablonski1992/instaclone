class Users::RegistrationsController < Devise::RegistrationsController

  def update
    @old_picture = resource.profile_picture
    super
  end
end
