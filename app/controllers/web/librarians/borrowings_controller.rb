module Web
  module Librarians
    class BorrowingsController < BaseController
      def update
        borrowing = ::Borrowing.find(params[:id])

        ::ActiveRecord::Base.transaction do
          borrowing.update!(returned_at: ::Time.current)

          book = borrowing.book

          if book.available_copies < book.total_copies
            book.increment!(:available_copies)
          end
        end

        redirect_to web_librarians_members_path, notice: "The book was returned."
      end
    end
  end
end
