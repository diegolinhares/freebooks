require "rails_helper"

::RSpec.describe ::Api::V1::Librarians::SessionsController, type: :request do
  fixtures :users

  let(:librarian) { users(:librarian) }
  let(:api_access_token) { librarian.api_access_token }

  describe "POST /api/v1/librarians/sessions" do
    context "when authenticated" do
      it "doesn't re-authenticate the user" do
        params = {
          user: {
            email: librarian.email,
            password: "12341234"
          }
        }

        post api_v1_librarians_sessions_path,
             params:,
             headers: { "Authorization" => "Bearer #{api_access_token}" },
             as: :json

        expect(response).to have_http_status(:forbidden)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "Action not allowed for authenticated librarian",
          details: {}
        )
      end
    end

    context "when unauthenticated" do
      it "authenticates the user when params are valid" do
        params = {
          user: {
            email: librarian.email,
            password: "12341234"
          }
        }

        post api_v1_librarians_sessions_path,
             params:,
             as: :json

        expect(response).to have_http_status(:ok)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "success",
          type: "object",
          data: hash_including(access_token: api_access_token)
        )
      end

      it "doesn't authenticate the user when params are invalid" do
        params = {
          user: {
            email: "bad-email",
            password: "bad-pass"
          }
        }

        post api_v1_librarians_sessions_path,
             params:,
             as: :json

        expect(response).to have_http_status(:unauthorized)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "Invalid email or password",
          details: {}
        )
      end
    end
  end

   describe "DELETE /api/v1/librarians/sessions" do
    context "when authenticated" do
      it "signs out the current librarian and regenerates the api_access_token" do
        delete api_v1_librarians_sessions_path,
               headers: { "Authorization" => "Bearer #{api_access_token}" },
               as: :json

        expect(response).to have_http_status(:ok)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "success"
        )

        librarian.reload

        expect(librarian.api_access_token).not_to eq(api_access_token)
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized status" do
        delete api_v1_librarians_sessions_path, as: :json

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
