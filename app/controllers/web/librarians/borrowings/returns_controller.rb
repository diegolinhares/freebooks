module Web
  module Librarians
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
              redirect_to web_librarians_members_path,
                          notice: "The book was returned."
            end

            transaction.after_rollback do
              redirect_to web_librarians_members_path,
                          notice: "Failed to mark book as returned."
            end
          end
        end
      end
    end
  end
end
