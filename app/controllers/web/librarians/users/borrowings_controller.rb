module Web
  module Librarians
    module Users
      class BorrowingsController < BaseController
        include ::Pagy::Backend

        def index
          borrowings = ::Borrowing.joins(:book)
                                  .where(user_id: params[:user_id])
                                  .select(:id)
                                  .select("books.title AS book_title")
                                  .active

          pagy, borrowings = pagy(borrowings)

          render "web/librarians/users/borrowings/index",
                locals: {
                  pagy:,
                  borrowings:
                }
        end
      end
    end
  end
end
