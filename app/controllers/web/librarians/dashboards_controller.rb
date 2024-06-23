module Web
  module Librarians
    class DashboardsController < BaseController
      def index
        books = ::Book.count

        total_borrowed_books = ::Borrowing.active.count
        books_due_today = ::Borrowing.due_today.count

        render "web/librarians/dashboard/index",
              locals: {
                books:,
                total_borrowed_books:,
                books_due_today:,
              }
      end
    end
  end
end
