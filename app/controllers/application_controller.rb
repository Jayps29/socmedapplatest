class ApplicationController < ActionController::Base
  include Pagy::Method

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path,
                alert: "You are not authorized to perform this action."
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [ :username, :first_name, :last_name, :bio, :avatar ]
    )

    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [ :username, :first_name, :last_name, :bio, :avatar ]
    )
  end
end
