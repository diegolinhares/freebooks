class Genre < ::ApplicationRecord
  include ::Litesearch::Model

  litesearch do |schema|
    schema.field :name
  end

  has_many :books,
           dependent: :destroy,
           inverse_of: :genre

  with_options presence: true do
    validates :name, uniqueness: true
  end

  scope :ordered, -> { order(name: :asc) }
end
