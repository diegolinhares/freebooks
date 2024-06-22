module Web
  module Librarians
    class SessionsController < BaseController
      skip_before_action :authenticate_librarian!

      def new
        render "web/librarians/sessions/new", locals: { user: ::User.new }
      end

      def create
        user = ::User.authenticate_by(
          email: user_params[:email],
          password: user_params[:password]
        )

        if user&.librarian?
          sign_in(user)

          redirect_to web_librarians_books_path, notice: "You have successfully signed in!"
        else
          flash.now[:alert] = "Invalid email or password"

          user = ::User.new(email: user_params[:email])

          render "web/librarians/sessions/new",
                 status: :unprocessable_entity,
                 locals: { user: }
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
