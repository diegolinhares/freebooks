module Api::V1::Librarians
  class MembersController < BaseController
    include ::Pagy::Backend

    def index
      members = ::User.joins(:borrowings)
                       .where('borrowings.due_date < ?', ::Date.today)
                       .where(borrowings: { returned_at: nil })
                       .where(role: :member)
                       .distinct
                       .select(:id, :email)

      pagy, members = pagy_array(members)

      pagy_headers_merge(pagy)

      render_json_with_success(status: :ok, data: {members:}, pagy:)
    end
  end
end
