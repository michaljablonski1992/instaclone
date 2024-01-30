class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:privacy_policy, :data_deletion_info]
end
