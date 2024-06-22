class BookPolicy < ::ApplicationPolicy
  def create?
    user.librarian?
  end

  def update?
    user.librarian?
  end

  def destroy?
    user.librarian?
  end
end
