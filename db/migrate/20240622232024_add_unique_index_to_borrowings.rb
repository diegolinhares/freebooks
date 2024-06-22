class AddUniqueIndexToBorrowings < ::ActiveRecord::Migration[7.1]
  def change
    add_index :borrowings,
              [:user_id, :book_id],
              where: "returned_at IS NULL",
              unique: true,
              name: "unique_borrowing_index"
  end
end
