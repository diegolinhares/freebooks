require "rails_helper"

::RSpec.describe ::Api::V1::Members::RegistrationsController, type: :request do
  fixtures :users

  describe "POST /api/v1/members/registrations" do
    context "when unauthenticated" do
      it "registers a new member with valid params" do
        params = {
          user: {
            email: "new_member@example.com",
            password: "password123"
          }
        }

        post api_v1_members_registrations_path,
             params:,
             as: :json

        expect(response).to have_http_status(:created)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "success",
          type: "object",
          data: hash_including(
            message: "Member registered successfully",
            access_token: be_a(String)
          )
        )
      end

      it "returns an error when params are invalid" do
        params = {
          user: {
            email: "invalid_email",
            password: ""
          }
        }

        post api_v1_members_registrations_path,
             params:,
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "Failed to register member",
          details: array_including(
            /Email is invalid/, /Password can't be blank/
          )
        )
      end
    end

    context "when authenticated" do
      let(:member) { users(:samuel_tarly) }
      let(:api_access_token) { member.api_access_token }

      it "doesn't allow authenticated members to register again" do
        params = {
          user: {
            email: "new_member@example.com",
            password: "password123"
          }
        }

        post api_v1_members_registrations_path,
             params:,
             headers: { "Authorization" => "Bearer #{api_access_token}" },
             as: :json

        expect(response).to have_http_status(:forbidden)

        body = ::JSON.parse(response.body).deep_symbolize_keys

        expect(body).to match(
          status: "error",
          message: "Action not allowed for authenticated member",
          details: {}
        )
      end
    end
  end
end
