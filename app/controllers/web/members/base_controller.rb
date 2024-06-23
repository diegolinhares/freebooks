module Web
  module Members
    class BaseController < ::ApplicationController
      layout "web/members/application"

      authorize :user, through: :current_member

      before_action :authenticate_member!

      private

      helper_method def member_signed_in?
        current_member.present?
      end

      helper_method def current_member
        return unless current_user_id?

        user = ::User.find(current_user_id)

        return unless user.member?

        ::Current.user = user
      end

      def authenticate_member!
        return if current_member

        redirect_to new_web_members_session_path,
                    alert: "You need to sign in before continuing."
      end

      def disallow_authenticated_member!
        return if current_member.blank?

        redirect_to web_members_root_path,
                    alert: "Action not allowed for authenticated member."
      end
    end
  end
end
