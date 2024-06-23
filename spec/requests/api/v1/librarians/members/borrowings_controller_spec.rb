require "rails_helper"

::RSpec.describe ::Api::V1::Librarians::Members::BorrowingsController, type: :request do
  fixtures :users, :books, :borrowings

  let(:librarian) { users(:librarian) }
  let(:member) { users(:samuel_tarly) }
  let(:api_access_token) { librarian.api_access_token }

  describe "GET /api/v1/librarians/members/:member_id/borrowings" do
    context "when authenticated" do
      it "returns paginated borrowings for the member" do
        get api_v1_librarians_member_borrowings_path(member_id: member.id),
            headers: { "Authorization" => "Bearer #{api_access_token}" },
            as: :json

        expect(response).to have_http_status(:ok)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expected_titles = ["Expired Book", "A Game of Thrones", "Dune"]

        borrowings_titles = body.dig(:data, :borrowings).map { _1[:book_title] }

        expect(borrowings_titles).to match_array(expected_titles)
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized status" do
        get api_v1_librarians_member_borrowings_path(member_id: member.id), as: :json

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
