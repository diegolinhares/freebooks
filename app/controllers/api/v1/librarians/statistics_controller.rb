module Api::V1::Librarians
  class StatisticsController < BaseController
    def index
      books = ::Book.count
      total_borrowed_books = ::Borrowing.active.count
      books_due_today = ::Borrowing.due_today.count

      render_json_with_success(
        status: :ok,
        data: {
          books: books,
          total_borrowed_books: total_borrowed_books,
          books_due_today: books_due_today
        }
      )
    end
  end
end
