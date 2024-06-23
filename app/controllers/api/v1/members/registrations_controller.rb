module Api::V1::Members
  class RegistrationsController < BaseController
    skip_before_action :authenticate_member!

    before_action :disallow_authenticated_member!

    def create
      member = ::User.new(user_params.with_defaults(role: :member))

      if member.save
        render_json_with_success(
          status: :created,
          data: {
            message: "Member registered successfully",
            access_token: member.api_access_token
          })
      else
        render_json_with_error(
          status: :unprocessable_entity,
          message: "Failed to register member",
          details: member.errors.full_messages
        )
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :password)
    end
  end
end
