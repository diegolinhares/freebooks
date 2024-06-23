require "rails_helper"

::RSpec.describe ::Api::V1::Librarians::StatisticsController, type: :request do
  fixtures :users, :books, :borrowings

  let(:librarian) { users(:librarian) }
  let(:api_access_token) { librarian.api_access_token }

  describe "GET /api/v1/librarians/statistics" do
    context "when authenticated" do
      it "returns dashboard statistics for the librarian" do
        get api_v1_librarians_statistics_path,
            headers: { "Authorization" => "Bearer #{api_access_token}" },
            as: :json

        expect(response).to have_http_status(:ok)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expected_body = {
          status: "success",
          data: {
            books: 17,
            total_borrowed_books: 13,
            books_due_today: 0
          },
          type: "object"
        }

        expect(body).to match(expected_body)
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized status" do
        get api_v1_librarians_statistics_path, as: :json

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
