module Api::V1::Librarians
  module Members
    class BorrowingsController < BaseController
      include ::Pagy::Backend

      def index
        borrowings = ::Borrowing.joins(:book)
                                .where(user_id: params[:member_id])
                                .select(:id, "books.title AS book_title")
                                .active

        pagy, borrowings = pagy(borrowings)

        pagy_headers_merge(pagy)

        render_json_with_success(status: :ok, data: { borrowings: }, pagy:)
      end
    end
  end
end
