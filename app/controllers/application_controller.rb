class ApplicationController < ::ActionController::Base
  def current_user_id
    session[:user_id]
  end

  def current_user_id?
    current_user_id.present?
  end

  def sign_in(user)
    ::Current.reset

    reset_session

    session[:user_id] = user.id
  end

  def sign_out
    ::Current.reset

    reset_session
  end
end
