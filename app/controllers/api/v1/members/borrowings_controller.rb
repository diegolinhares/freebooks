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

    def create
      book = ::Book.find(params[:book_id])

      if book.available_copies > 0
        book.with_lock do
          borrowing = current_member.borrowings.build(
            book: book,
            borrowed_at: ::Time.current,
            due_date: 2.weeks.from_now
          )

          if borrowing.save
            book.decrement!(:available_copies)

            render_json_with_success(status: :created, data: { message: "Book successfully borrowed." })
          else
            render_json_with_error(status: :unprocessable_entity, message: "Failed to borrow book", details: borrowing.errors.full_messages)
          end
        end
      else
        render_json_with_error(status: :unprocessable_entity, message: "No available copies to borrow.")
      end
    end
  end
end
