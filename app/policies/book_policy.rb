class BookPolicy < ::ApplicationPolicy
  def create?
    user.librarian?
  end

  def destroy?
    user.librarian?
  end
end
