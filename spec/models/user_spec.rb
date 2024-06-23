require "rails_helper"

::RSpec.describe ::User, type: :model do
  fixtures :users, :borrowings

  describe "associations" do
    it { should have_many(:borrowings).dependent(:destroy).inverse_of(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }

    it { should validate_uniqueness_of(:email).case_insensitive }

    it { should allow_value("example@example.com").for(:email) }
    it { should_not allow_value("example.com").for(:email) }

    it { should validate_length_of(:password).is_at_least(8).on(:create) }
    it { should validate_confirmation_of(:password) }

    it { should have_secure_password }

    it { should have_secure_token(:api_access_token) }
  end

  describe "enums" do
    it "defines the enum for role with correct values" do
      expect(::User.roles).to include("librarian" => "librarian", "member" => "member")
    end
  end
end
