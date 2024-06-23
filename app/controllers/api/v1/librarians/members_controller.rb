module Api::V1::Librarians
  class MembersController < BaseController
    include ::Pagy::Backend

    def index
      members = ::User.select(:id, :email).with_overdue_books

      pagy, members = pagy_array(members)

      pagy_headers_merge(pagy)

      render_json_with_success(status: :ok, data: {members:}, pagy:)
    end
  end
end
