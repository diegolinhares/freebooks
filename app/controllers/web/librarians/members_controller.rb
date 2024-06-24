module Web
  module Librarians
    class MembersController < BaseController
      include ::Pagy::Backend

      def index
        members = ::User.joins(:borrowings)
                        .where('borrowings.due_date < ?', ::Date.today)
                        .where(borrowings: { returned_at: nil })
                        .where(role: :member)
                        .distinct
                        .select(:id, :email)

        pagy, members = pagy(members)

        render "web/librarians/members/index",
              locals: {
                pagy:,
                members:
              }
      end
    end
  end
end
