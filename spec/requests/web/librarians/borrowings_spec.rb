require 'rails_helper'

RSpec.describe "Web::Librarians::Borrowings", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/web/librarians/borrowings/index"
      expect(response).to have_http_status(:success)
    end
  end

end
