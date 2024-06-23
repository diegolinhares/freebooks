class Book < ::ApplicationRecord
  include ::Litesearch::Model

  litesearch do |schema|
    schema.field :title, weight: 5
    schema.field :author, target: "authors.name"
    schema.field :genre, target: "genres.name"
    schema.tokenizer :trigram
  end

  belongs_to :author, inverse_of: :books
  belongs_to :genre, inverse_of: :books

  has_many :borrowings,
           dependent: :destroy,
           inverse_of: :book

  with_options presence: true do
    validates :title
    validates :author
    validates :genre
    validates :isbn, uniqueness: true
    validates :total_copies, numericality: { greater_than: 0 }
  end
end
