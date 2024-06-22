require 'rails_helper'

RSpec.describe "Web::Librarians::Books", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/web/librarians/books/index"
      expect(response).to have_http_status(:success)
    end
  end

end
