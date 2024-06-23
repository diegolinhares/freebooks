require "rails_helper"

::RSpec.describe ::Api::V1::Librarians::Borrowings::ReturnsController, type: :request do
  fixtures :users, :borrowings

  let(:librarian) { users(:librarian) }
  let(:api_access_token) { librarian.api_access_token }
  let(:borrowing) { borrowings(:borrowing_one) }

  describe "PATCH /api/v1/librarians/borrowings/:borrowing_id/return" do
    context "when authenticated" do
      it "marks the book as returned" do
        patch api_v1_librarians_borrowing_return_path(borrowing_id: borrowing.id),
              headers: { "Authorization" => "Bearer #{api_access_token}" },
              as: :json

        expect(response).to have_http_status(:ok)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "success",
          data: {
            message: "Book marked as returned."
          },
          type: "object"
        )

        expect(borrowing.reload.returned_at).not_to be_nil
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized status" do
        patch api_v1_librarians_borrowing_return_path(borrowing_id: borrowing.id), as: :json

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
