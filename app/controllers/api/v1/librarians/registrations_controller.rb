module Api::V1::Librarians
  class RegistrationsController < BaseController
    skip_before_action :authenticate_librarian!

    before_action :disallow_authenticated_librarian!

    def create
      librarian = ::User.new(user_params.with_defaults(role: :librarian))

      if librarian.save
        render_json_with_success(
          status: :created,
          data: {
            message: "Librarian registered successfully",
            access_token: librarian.api_access_token
          })
      else
        render_json_with_error(
          status: :unprocessable_entity,
          message: "Failed to register librarian",
          details: librarian.errors.full_messages
        )
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :password)
    end
  end
end
