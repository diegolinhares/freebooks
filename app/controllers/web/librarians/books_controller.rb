module Web
  module Librarians
    class BooksController < BaseController
      authorize :user, through: :current_librarian

      def index
        books = ::Book.all

        render "web/librarians/books/index", locals: { books: }
      end

      def new
        render "web/librarians/books/new", locals: { book: ::Book.new }
      end

      def create
        book = ::Book.new(book_params)

        authorize! book

        if book.save
          redirect_to web_librarians_books_path, notice: "Book created"
        else
          render "web/librarians/books/new",
                 status: :unprocessable_entity,
                 locals: {book:}
        end
      end

      private

      def book_params
        params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies)
      end
    end
  end
end
