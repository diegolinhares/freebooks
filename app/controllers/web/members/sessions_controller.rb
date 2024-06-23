module Web
  module Members
    class SessionsController < BaseController
      layout "web/application"

      skip_before_action :authenticate_member!, only: [:new, :create]

      before_action :disallow_authenticated_member!, only: [:new, :create]
      before_action :authenticate_member!, only: [:destroy]

      def new
        render "web/members/sessions/new", locals: { user: ::User.new }
      end

      def create
        user = ::User.authenticate_by(
          email: user_params[:email],
          password: user_params[:password]
        )

        if user&.member?
          sign_in(user)

          redirect_to web_members_books_path,
                      notice: "You have successfully signed in!"
        else
          flash.now[:alert] = "Invalid email or password"

          user = ::User.new(email: user_params[:email])

          render "web/members/sessions/new",
                 status: :unprocessable_entity,
                 locals: { user: }
        end
      end

      def destroy
        sign_out

        redirect_to web_members_root_path,
                    notice: "You have successfully signed out!"
      end

      private

      def user_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
