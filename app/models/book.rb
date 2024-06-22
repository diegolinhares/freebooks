class Book < ::ApplicationRecord
  include ::Litesearch::Model

  litesearch do |schema|
    schema.fields [:title, :author, :genre]
    schema.tokenizer :porter
  end

  GENRES = [
    "Fantasy",
    "Science Fiction",
    "Mystery",
    "Thriller",
    "Romance",
    "Historical Fiction",
    "Horror",
    "Non-fiction",
    "Biography",
    "Young Adult",
    "Children",
    "Adventure"
  ].freeze

  with_options presence: true do
    validates :title
    validates :author
    validates :genre, inclusion: { in: GENRES }
    validates :isbn, uniqueness: true
    validates :total_copies, numericality: { greater_than: 0 }
  end
end
