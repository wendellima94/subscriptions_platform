class ApplicationController < ActionController::Base
  helper_method :current_user, :user_signed_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end

  def require_authentication
    return if user_signed_in?

    redirect_to login_path, alert: "Você precisa entrar para continuar."
  end

  def require_admin
    return if current_user&.role_admin?

    redirect_to root_path, alert: "Você não tem permissão para acessar essa área."
  end
end
