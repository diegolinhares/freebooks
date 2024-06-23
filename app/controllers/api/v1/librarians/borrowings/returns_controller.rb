module Api::V1::Librarians
  module Borrowings
    class ReturnsController < BaseController
      def update
        borrowing = ::Borrowing.find(params[:borrowing_id])

        borrowing.update!(returned_at: ::Time.current)

        render_json_with_success(
          status: :ok,
          data: {
            message: "Book marked as returned."
          })
      end
    end
  end
end
