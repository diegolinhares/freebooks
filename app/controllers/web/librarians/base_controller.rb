module Web
  module Librarians
    class BaseController < ::ApplicationController
      layout "web/librarians/application"

      authorize :user, through: :current_librarian

      before_action :authenticate_librarian!

      private

      helper_method def librarian_signed_in?
        current_librarian.present?
      end

      helper_method def current_librarian
        return unless current_user_id?

        user = ::User.find(current_user_id)

        return unless user.librarian?

        ::Current.user = user
      end

      def authenticate_librarian!
        return if current_librarian

        redirect_to new_web_librarians_session_path, alert: "You need to sign in before continuing."
      end
    end
  end
end
