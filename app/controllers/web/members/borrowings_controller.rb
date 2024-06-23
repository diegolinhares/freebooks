module Web
  module Members
    class BorrowingsController < BaseController
      include ::Pagy::Backend

      def index
        borrowings = ::Borrowing.joins(:book)
                                .where(user: current_member)
                                .select(:id, :due_date)
                                .select("books.title AS book_title")
                                .select("CASE WHEN due_date < datetime('now') THEN 'overdue' ELSE 'not overdue' END AS status")

        pagy, borrowings = pagy(borrowings)

        render "web/members/borrowings/index", locals: { borrowings:, pagy: }
      end

      def create
        book = ::Book.find(params[:book_id])

        if book.available_copies > 0
          ::ActiveRecord::Base.transaction do
            borrowing = current_member.borrowings.build(
              book:,
              borrowed_at: ::Time.current,
              due_date: 2.weeks.from_now
            )

            if borrowing.save
              book.decrement!(:available_copies)

              redirect_to web_members_root_path, notice: 'Book successfully borrowed.'
            else
              redirect_to web_members_root_path, alert: borrowing.errors.full_messages.first
            end
          end
        else
          redirect_to web_members_root_path, alert: 'No available copies to borrow.'
        end
      end
    end
  end
end
