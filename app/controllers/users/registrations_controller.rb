class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_navbar_elements, only: [:edit, :update, :danger_zone]

  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    @old_picture = resource.profile_picture
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = if resource.from_omniauth?
      update_resource_wo_password(resource, account_update_params)
    else
      update_resource(resource, account_update_params)
    end
    yield resource if block_given?
    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def delete_account
    current_user.destroy!
    flash[:notice] = t('views.devise.delete_account_success')
    redirect_to new_user_session_path
  rescue
    flash[:alert] = t('something_went_wrong')
    redirect_to users_danger_zone_path
  end
  private

  def after_inactive_sign_up_path_for(resource_or_scope)
    new_user_session_path
  end

  # By default we want to require a password checks on update.
  # You can overwrite this method in your own RegistrationsController.
  def update_resource_wo_password(resource, params)
    resource.update_without_password(params)
  end

  def set_navbar_elements
    @navbar_elements = {
      edit_user_registration_path => {
        text: t('views.devise.edit_profile'),
        active: ['edit', 'update'].include?(action_name)
      },
      users_danger_zone_path => {
        text: t('views.devise.danger_zone'),
        active: ['danger_zone', 'delete_account'].include?(action_name),
        klass: ['text-danger']
      }
    }
  end
end
