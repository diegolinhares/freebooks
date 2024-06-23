module Web
  module Librarians
    class BorrowingsController < BaseController
      def update
        borrowing = ::Borrowing.find(params[:id])

        ::ActiveRecord::Base.transaction do
          borrowing.update!(returned_at: ::Time.current)

          book = borrowing.book

          book.increment!(:available_copies) if book.available_copies < book.total_copies
        end

        redirect_to web_librarians_users_path
      end
    end
  end
end
