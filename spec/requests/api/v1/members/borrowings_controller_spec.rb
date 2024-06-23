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
            ],
            pagy: hash_including(
              count: 3,
              from: 1,
              in: 3,
              items: 5,
              last: 1,
              next: nil,
              offset: 0,
              outset: 0,
              page: 1,
              prev: nil,
              to: 3,
              vars: hash_including(
                count: 3,
                count_args: ["all"],
                headers: hash_including(
                  count: "total-count",
                  items: "page-items",
                  page: "current-page",
                  pages: "total-pages"
                ),
                items: 5,
                outset: 0,
                page: 1,
                page_param: "page",
                size: 7
              )
            )
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
end
