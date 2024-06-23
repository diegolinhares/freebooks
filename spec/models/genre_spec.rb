require "rails_helper"

::RSpec.describe ::Genre, type: :model do
  fixtures :genres, :books

  describe "associations" do
    it { should have_many(:books).dependent(:destroy).inverse_of(:genre) }
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
      it "returns genres ordered by name ascending" do
        genres = ::Genre.ordered

        expected_output = [
          "Adventure",
          "Biography",
          "Children",
          "Fantasy",
          "Fiction",
          "Historical Fiction",
          "Horror",
          "Mystery",
          "Non-fiction",
          "Romance",
          "Science Fiction",
          "Thriller",
          "Young Adult"
        ]

        expect(genres.pluck(:name)).to eq(expected_output)
      end
    end
  end
end