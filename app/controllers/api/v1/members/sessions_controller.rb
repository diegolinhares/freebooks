module Api::V1::Members
  class SessionsController < BaseController
    before_action :authenticate_member!, only: [:destroy]
    before_action :disallow_authenticated_member!, only: [:create]

    def create
      user = ::User.authenticate_by(
        email: user_params[:email],
        password: user_params[:password]
      )

      if user
        render_json_with_success(
          status: :ok,
          data: {
            access_token: user.api_access_token
          }
        )
      else
        render_json_with_error(
          status: :unauthorized,
          message: "Invalid email or password"
        )
      end
    end

    def destroy
      current_member.regenerate_api_access_token

      render_json_with_success(
        status: :ok
      )
    end

    private

    def user_params
      params.require(:user).permit(:email, :password)
    end
  end
end
