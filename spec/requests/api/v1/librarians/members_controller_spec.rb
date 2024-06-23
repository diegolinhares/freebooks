require "rails_helper"

::RSpec.describe ::Api::V1::Librarians::MembersController, type: :request do
  fixtures :users, :borrowings

  let(:librarian) { users(:librarian) }
  let(:api_access_token) { librarian.api_access_token }

  describe "GET /api/v1/librarians/members" do
    context "when authenticated" do
      it "returns paginated members with overdue books" do
        get api_v1_librarians_members_path,
            headers: { "Authorization" => "Bearer #{api_access_token}" },
            as: :json

        expect(response).to have_http_status(:ok)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expected_body = {
          status: "success",
          data: {
            members: array_including(
              hash_including(email: be_a(String))
            )
          },
          pagination: hash_including(
            count: be_a(Integer),
            items: be_a(Integer),
            next: be_a(Integer).or(be_nil),
            page: be_a(Integer),
            pages: be_a(Integer),
            prev: be_a(Integer).or(be_nil)
          ),
          type: "object"
        }

        expect(body).to match(expected_body)
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized status" do
        get api_v1_librarians_members_path, as: :json

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
