require "rails_helper"

::RSpec.describe ::Api::V1::Members::BorrowingsController, type: :request do
  fixtures :users, :borrowings, :books, :authors, :genres

  let(:samuel_tarly) { users(:samuel_tarly) }
  let(:api_access_token) { samuel_tarly.api_access_token }

  describe "GET /api/v1/members/borrowings" do
    context "when authenticated" do
      it "returns paginated borrowings for the current member" do
        get api_v1_members_borrowings_path,
            headers: { "Authorization" => "Bearer #{api_access_token}" },
            as: :json

        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body).deep_symbolize_keys

        expected_body = {
          status: "success",
          type: "object",
          data: {
            borrowings: [
              hash_including(
                book_title: "Expired Book",
                status: "overdue"
              ),
              hash_including(
                book_title: "A Game of Thrones",
                status: "not overdue"
              ),
              hash_including(
                book_title: "Dune",
                status: "not overdue"
              )
            ]
          },
          pagination: {
            count: 3,
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
        get api_v1_members_borrowings_path, as: :json

        expect(response).to have_http_status(:unauthorized)

        body = JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "Invalid access token",
          details: {}
        )
      end
    end
  end

  describe "POST /api/v1/members/borrowings" do
    let(:available_book) { books(:it) }
    let(:unavailable_book) { books(:sapiens) }
    let(:borrowed_book) { books(:dune) }

    context "when authenticated" do
      it "creates a borrowing successfully" do
        post api_v1_members_book_borrowings_path(book_id: available_book.id),
             headers: { "Authorization" => "Bearer #{api_access_token}" },
             as: :json

        expect(response).to have_http_status(:created)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "success",
          data: {
            message: "Book successfully borrowed."
          },
          type: "object"
        )

        expect(available_book.reload.available_copies).to eq(available_book.total_copies - 1)
      end

      it "fails to create a borrowing when no copies are available" do
        post api_v1_members_book_borrowings_path(book_id: unavailable_book.id),
             headers: { "Authorization" => "Bearer #{api_access_token}" },
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "No available copies to borrow.",
          details: {}
        )
      end

      it "returns an error when the user tries to borrow a book they have already borrowed and not returned" do
        post api_v1_members_book_borrowings_path(book_id: borrowed_book.id),
             headers: { "Authorization" => "Bearer #{api_access_token}" },
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "Failed to borrow book",
          details: ["User has already borrowed this book and not returned it yet"]
        )
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized status" do
        post api_v1_members_book_borrowings_path(book_id: unavailable_book.id),
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
