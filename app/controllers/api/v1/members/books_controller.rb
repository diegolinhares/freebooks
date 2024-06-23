module Api::V1::Members
  class BooksController < BaseController
    include ::Pagy::Backend

    def index
      books = ::Book.joins(:author, :genre)
                    .where("books.available_copies > 0")
                    .select(:id, :title)
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

      render_json_with_success(
        status: :ok,
        data: {books:},
        pagy:
      )
    end
  end
end
