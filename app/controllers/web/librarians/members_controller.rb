module Web
  module Librarians
    class MembersController < BaseController
      include ::Pagy::Backend

      def index
        members = ::User.with_overdue_books

        pagy, members = pagy(members)

        render "web/librarians/members/index",
              locals: {
                pagy:,
                members:
              }
      end
    end
  end
end
