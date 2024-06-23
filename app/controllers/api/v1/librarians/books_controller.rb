module Api::V1::Librarians
  class BooksController < BaseController
    include ::Pagy::Backend

    def index
      books = ::Book.joins(:author, :genre)
                    .select(books: [:id, :title])
                    .select("authors.name AS author_name")
                    .select("genres.name AS genre_name")

      books = books.search(params[:query]) if params[:query].present?

      case books
      in ::Array
        pagy, books = pagy_array(books)
      else
        pagy, books = pagy(books)
      end

      pagy_headers_merge(pagy)

      render_json_with_success(status: :ok, data: {books:}, pagy:)
    end
  end
end
