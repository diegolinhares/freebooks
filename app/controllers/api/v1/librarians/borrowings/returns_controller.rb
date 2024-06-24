module Api::V1::Librarians
  module Borrowings
    class ReturnsController < BaseController
      def update
        borrowing = ::Borrowing.find(params[:borrowing_id])

        ::ActiveRecord::Base.transaction do |transaction|
          borrowing.update!(returned_at: ::Time.current)

          book = borrowing.book

          if book.available_copies < book.total_copies
            book.increment!(:available_copies)
          end

          transaction.after_commit do
            render_json_with_success(
              status: :ok,
              data: {
                message: "Book marked as returned."
              }
            )
          end

          transaction.after_rollback do
            render_json_with_error(
              status: :unprocessable_entity,
              data: {
                message: "Failed to mark book as returned."
              }
            )
          end
        end
      end
    end
  end
end
