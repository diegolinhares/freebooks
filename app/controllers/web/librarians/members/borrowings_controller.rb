module Web
  module Librarians
    module Members
      class BorrowingsController < BaseController
        include ::Pagy::Backend

        def index
          borrowings = ::Borrowing.joins(:book)
                                  .where(user_id: params[:member_id])
                                  .select(:id, "books.title AS book_title")
                                  .active

          pagy, borrowings = pagy(borrowings)

          render "web/librarians/members/borrowings/index",
                locals: {
                  pagy:,
                  borrowings:
                }
        end
      end
    end
  end
end
