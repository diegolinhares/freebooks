class BookPolicy < ::ApplicationPolicy
  def create?
    user.librarian?
  end
end
