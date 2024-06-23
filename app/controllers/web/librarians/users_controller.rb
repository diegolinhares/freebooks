module Web
  module Librarians
    class UsersController < BaseController
      include ::Pagy::Backend

      def index
        members = ::User.with_overdue_books

        pagy, members = pagy(members)

        render "web/librarians/users/index",
              locals: {
                pagy:,
                members:
              }
      end
    end
  end
end
