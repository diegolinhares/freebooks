class Book < ::ApplicationRecord
  with_options presence: true do
    validates :title
    validates :author
    validates :genre
    validates :isbn, uniqueness: true
    validates :total_copies
  end
end
