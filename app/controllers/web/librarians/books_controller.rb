module Web
  module Librarians
    class BooksController < BaseController
      def index
        books = ::Book.all

        render "web/librarians/books/index", locals: { books: }
      end
    end
  end
end
