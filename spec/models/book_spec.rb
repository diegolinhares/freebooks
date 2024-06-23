require "rails_helper"

RSpec.describe ::Book, type: :model do
  fixtures :books, :authors, :genres

  describe "associations" do
    it { should belong_to(:author).inverse_of(:books) }
    it { should belong_to(:genre).inverse_of(:books) }
    it { should have_many(:borrowings).dependent(:destroy).inverse_of(:book) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:genre) }
    it { should validate_uniqueness_of(:isbn).case_insensitive }
    it { should validate_numericality_of(:total_copies).is_greater_than(0) }
  end

  describe "indexes" do
    it { should have_db_index(:isbn).unique(true) }
  end
end
