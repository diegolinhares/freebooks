class User < ::ApplicationRecord
  has_secure_token :api_access_token, length: 42

  has_secure_password

  has_many :borrowings,
           dependent: :destroy,
           inverse_of: :user

  with_options presence: true do
    validates :password,
              confirmation: true,
              length: {minimum: 8}, if: -> { new_record? || password.present? }

    validates :email,
              format: {with: ::URI::MailTo::EMAIL_REGEXP},
              uniqueness: true
  end

  normalizes :email, with: -> { _1.strip.downcase }

  enum role: {
    librarian: "librarian",
    member: "member"
  }

  scope :with_overdue_books, -> {
    joins(:borrowings)
      .where("borrowings.due_date < ? AND borrowings.returned_at IS NULL", ::Date.today)
      .where(role: "member")
      .distinct
  }
end
