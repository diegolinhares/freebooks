module Api::V1::Members
  class BorrowingsController < BaseController
    include ::Pagy::Backend

    def index
      borrowings = ::Borrowing.joins(:book)
                              .where(user: current_member)
                              .select(:id, :due_date)
                              .select("books.title AS book_title")
                              .select("CASE WHEN due_date < datetime('now') THEN 'overdue' ELSE 'not overdue' END AS status")

      pagy, borrowings = pagy(borrowings)

      pagy_headers_merge(pagy)

      render_json_with_success(status: :ok, data: {borrowings:, pagy:})
    end
  end
end
