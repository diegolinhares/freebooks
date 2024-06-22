class Borrowing < ApplicationRecord
  belongs_to :user, inverse_of: :borrowings
  belongs_to :book, inverse_of: :borrowings
end
