module Web
  module Librarians
    class BorrowingsController < BaseController
      include ::Pagy::Backend

      def index
        members = ::User.with_overdue_books

        pagy, members = pagy(members)

        render "web/librarians/borrowings/index",
              locals: {
                pagy:,
                members:
              }
      end
    end
  end
end
