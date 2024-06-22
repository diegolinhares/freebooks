class Borrowing < ::ApplicationRecord
  belongs_to :user, inverse_of: :borrowings
  belongs_to :book, inverse_of: :borrowings

  with_options presence: true do
    validates :borrowed_at
    validates :due_date
  end

  validates :user_id,
            uniqueness: {
              scope: :book_id,
              conditions: -> { where(returned_at: nil) },
              message: "has already borrowed this book and not returned it yet"
            }
end
