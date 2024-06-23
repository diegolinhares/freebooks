require "rails_helper"

::RSpec.describe ::Api::V1::Librarians::BooksController, type: :request do
  fixtures :users, :books, :authors, :genres

  let(:librarian) { users(:librarian) }
  let(:api_access_token) { librarian.api_access_token }

  describe "GET /api/v1/librarians/books" do
    context "when authenticated" do
      it "returns paginated books for the librarian" do
        get api_v1_librarians_books_path,
            headers: { "Authorization" => "Bearer #{api_access_token}" },
            as: :json

        expect(response).to have_http_status(:ok)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expected_body = {
          status: "success",
          type: "object",
          data: {
            books: [
              hash_including(
                title: "A Feast for Crows",
                author_name: "George R. R. Martin",
                genre_name: "Fantasy"
              ),
              hash_including(
                title: "Sapiens: A Brief History of Humankind",
                author_name: "Yuval Noah Harari",
                genre_name: "Non-fiction"
              ),
              hash_including(
                title: "Dune",
                author_name: "Frank Herbert",
                genre_name: "Science Fiction"
              ),
              hash_including(
                title: "A Dance with Dragons",
                author_name: "George R. R. Martin",
                genre_name: "Fantasy"
              ),
              hash_including(
                title: "The Book Thief",
                author_name: "Markus Zusak",
                genre_name: "Historical Fiction"
              )
            ]
          },
          pagination: {
            count: 17,
            items: 5,
            next: 2,
            page: 1,
            pages: 4,
            prev: nil
          }
        }

        expect(body).to match(expected_body)
      end

      it "returns paginated books for the search query" do
        get api_v1_librarians_books_path(query: "Dune"),
            headers: { "Authorization" => "Bearer #{api_access_token}" },
            as: :json

        expect(response).to have_http_status(:ok)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expected_body = {
          status: "success",
          type: "object",
          data: {
            books: [
              hash_including(
                title: "Dune",
                author_name: "Frank Herbert",
                genre_name: "Science Fiction"
              )
            ]
          },
          pagination: {
            count: 1,
            items: 5,
            next: nil,
            page: 1,
            pages: 1,
            prev: nil
          }
        }

        expect(body).to match(expected_body)
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized status" do
        get api_v1_librarians_books_path, as: :json

        expect(response).to have_http_status(:unauthorized)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "Invalid access token",
          details: {}
        )
      end
    end
  end

  describe "POST /api/v1/librarians/books" do
    context "when authenticated" do
      let(:valid_params) do
        {
          book: {
            title: "New Book",
            author_id: authors(:george_rr_martin).id,
            genre_id: genres(:fantasy).id,
            isbn: "978-1234567890",
            total_copies: 10,
            available_copies: 10
          }
        }
      end

      it "creates a book successfully" do
        post api_v1_librarians_books_path,
             params: valid_params,
             headers: { "Authorization" => "Bearer #{api_access_token}" },
             as: :json

        expect(response).to have_http_status(:created)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "success",
          data: hash_including(
            message: "Book created",
            book: hash_including(
              title: "New Book"
            )
          ),
          type: "object"
        )
      end

      it "fails to create a book due to validation errors" do
        invalid_params = valid_params.deep_merge(book: { title: "" })

        post api_v1_librarians_books_path,
             params: invalid_params,
             headers: { "Authorization" => "Bearer #{api_access_token}" },
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "Failed to create book",
          details: array_including("Title can't be blank")
        )
      end
    end

    context "when unauthenticated" do
      let(:valid_params) do
        {
          book: {
            title: "New Book",
            author_id: authors(:george_rr_martin).id,
            genre_id: genres(:fantasy).id,
            isbn: "978-1234567890",
            total_copies: 10,
            available_copies: 10
          }
        }
      end

      it "returns unauthorized status" do
        post api_v1_librarians_books_path,
             params: valid_params,
             as: :json

        expect(response).to have_http_status(:unauthorized)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "Invalid access token",
          details: {}
        )
      end
    end
  end

  describe "PUT /api/v1/librarians/books/:id" do
    let(:existing_book) { books(:dune) }

    context "when authenticated" do
      let(:valid_params) do
        {
          book: {
            title: "Updated Book Title",
            author_id: authors(:george_rr_martin).id,
            genre_id: genres(:fantasy).id,
            isbn: "978-1234567890",
            total_copies: 10,
            available_copies: 10
          }
        }
      end

      it "updates a book successfully" do
        put api_v1_librarians_book_path(existing_book),
            params: valid_params,
            headers: { "Authorization" => "Bearer #{api_access_token}" },
            as: :json

        expect(response).to have_http_status(:ok)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "success",
          data: hash_including(
            message: "Book updated",
            book: hash_including(
              title: "Updated Book Title"
            )
          ),
          type: "object"
        )
      end

      it "fails to update a book due to validation errors" do
        invalid_params = valid_params.deep_merge(book: { title: "" })

        put api_v1_librarians_book_path(existing_book),
            params: invalid_params,
            headers: { "Authorization" => "Bearer #{api_access_token}" },
            as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "Failed to update book",
          details: array_including("Title can't be blank")
        )
      end
    end

    context "when unauthenticated" do
      let(:valid_params) do
        {
          book: {
            title: "Updated Book Title",
            author_id: authors(:george_rr_martin).id,
            genre_id: genres(:fantasy).id,
            isbn: "978-1234567890",
            total_copies: 10,
            available_copies: 10
          }
        }
      end

      it "returns unauthorized status" do
        put api_v1_librarians_book_path(existing_book),
            params: valid_params,
            as: :json

        expect(response).to have_http_status(:unauthorized)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "Invalid access token",
          details: {}
        )
      end
    end
  end
end
