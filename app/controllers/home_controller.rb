class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:privacy_policy]
end
