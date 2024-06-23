require "rails_helper"

RSpec.describe ::Api::V1::Librarians::RegistrationsController, type: :request do
  fixtures :users

  describe "POST /api/v1/librarians/registrations" do
    context "when unauthenticated" do
      it "registers a new librarian and returns access token" do
        params = {
          user: {
            email: "librarian@example.com",
            password: "password123"
          }
        }

        post api_v1_librarians_registrations_path,
             params:,
             as: :json

        expect(response).to have_http_status(:created)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "success",
          data: hash_including(
            message: "Librarian registered successfully",
            access_token: be_a(String)
          ),
          type: "object"
        )
      end

      it "returns errors when registration fails" do
        params = {
          user: {
            email: "",
            password: "password123"
          }
        }

        post api_v1_librarians_registrations_path,
             params:,
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "Failed to register librarian",
          details: array_including("Email can't be blank")
        )
      end
    end

    context "when authenticated" do
      let(:librarian) { users(:librarian) }
      let(:api_access_token) { librarian.api_access_token }

      it "disallows authenticated librarian from registering" do
        params = {
          user: {
            email: "librarian2@example.com",
            password: "password123"
          }
        }

        post api_v1_librarians_registrations_path,
             params: params,
             headers: { "Authorization" => "Bearer #{api_access_token}" },
             as: :json

        expect(response).to have_http_status(:forbidden)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          details: {},
          message: "Action not allowed for authenticated librarian"
        )
      end
    end
  end
end
