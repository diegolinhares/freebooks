require "rails_helper"

::RSpec.describe ::Author, type: :model do
  fixtures :authors, :books

  describe "associations" do
    it { should have_many(:books).dependent(:destroy).inverse_of(:author) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe "indexes" do
    it { should have_db_index(:name).unique(true) }
  end

  describe "scopes" do
    describe ".ordered" do
      it "returns authors ordered by name ascending" do
        authors = ::Author.ordered

        expected_output = [
          "Dan Brown",
          "E.B. White",
          "Frank Herbert",
          "George R. R. Martin",
          "Gillian Flynn",
          "J.R.R. Tolkien",
          "Jane Austen",
          "John Green",
          "Markus Zusak",
          "Stephen King",
          "Unknown Author",
          "Walter Isaacson",
          "Yuval Noah Harari"
        ]

        expect(authors.pluck(:name)).to eq(expected_output)
      end
    end
  end
end
