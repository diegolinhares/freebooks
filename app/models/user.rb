class User < ::ApplicationRecord
  has_secure_password

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
end
