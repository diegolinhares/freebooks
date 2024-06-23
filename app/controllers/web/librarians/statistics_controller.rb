module Web
  module Librarians
    class StatisticsController < BaseController
      def index
        books = ::Book.count

        total_borrowed_books = ::Borrowing.active.count
        books_due_today = ::Borrowing.due_today.count

        render "web/librarians/statistics/index",
               locals: {
                 books:,
                 total_borrowed_books:,
                 books_due_today:,
               }
      end
    end
  end
end
