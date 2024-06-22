module Web
  module Librarians
    class BooksController < BaseController
      authorize :user, through: :current_librarian

      def index
        books = ::Book.joins(:genre)
                      .select(books: [:id, :title, :author])
                      .select("genres.name AS genre_name")

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

      def edit
        book = ::Book.find(params[:id])

        render "web/librarians/books/edit", locals: { book: }
      end

      def update
        book = ::Book.find(params[:id])

        authorize! book

        if book.update(book_params)
          redirect_to web_librarians_books_path, notice: "Book updated"
        else
          render "web/librarians/books/edit",
                 status: :unprocessable_entity,
                 locals: {book:}
        end
      end

      def destroy
        book = ::Book.find(params[:id])

        book.destroy!

        redirect_to web_librarians_books_path, notice: "Book deleted"
      end

      private

      def book_params
        params.require(:book).permit(:title, :author, :genre_id, :isbn, :total_copies)
      end
    end
  end
end
