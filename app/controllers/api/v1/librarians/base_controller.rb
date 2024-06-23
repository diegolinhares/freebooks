module Api::V1::Librarians
  class BaseController < ::Api::V1::BaseController
    include ::ActionPolicy::Controller

    before_action :authenticate_librarian!

    authorize :user, through: :current_librarian

    protected

    def authenticate_librarian!
      return if current_librarian

      render_json_with_error(status: :unauthorized, message: "Invalid access token")
    end

    def disallow_authenticated_librarian!
      return if current_librarian.blank?

      render_json_with_error(status: :forbidden, message: "Action not allowed for authenticated librarian")
    end

    def current_librarian
      Current.user ||= authenticate_with_http_token do |access_token|
        ::User.find_by(api_access_token: access_token, role: :librarian)
      end
    end
  end
end
