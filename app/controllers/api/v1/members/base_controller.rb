module Api::V1::Members
  class BaseController < ::Api::V1::BaseController
    before_action :authenticate_member!

    protected

    def authenticate_member!
      return if current_member

      render_json_with_error(status: :unauthorized, message: "Invalid access token")
    end

    def disallow_authenticated_member!
      return if current_member.blank?

      render_json_with_error(status: :unauthorized, message: "Action not allowed for authenticated member")
    end

    def current_member
      Current.user ||= authenticate_with_http_token do |access_token|
        ::User.find_by(api_access_token: access_token, role: :member)
      end
    end
  end
end
