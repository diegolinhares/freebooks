class Book < ::ApplicationRecord
  include ::Litesearch::Model

  litesearch do |schema|
    schema.field :title, weight: 5
    schema.field :genre, target: "genres.name"
    schema.tokenizer :porter
  end

  belongs_to :genre, inverse_of: :books

  with_options presence: true do
    validates :title
    validates :author
    validates :genre
    validates :isbn, uniqueness: true
    validates :total_copies, numericality: { greater_than: 0 }
  end
end
