require "rails_helper"

::RSpec.describe ::Borrowing, type: :model do
  fixtures :borrowings, :users, :books

  describe "associations" do
    it { should belong_to(:user).inverse_of(:borrowings) }
    it { should belong_to(:book).inverse_of(:borrowings) }
  end

  describe "validations" do
    it { should validate_presence_of(:borrowed_at) }
    it { should validate_presence_of(:due_date) }
  end
end