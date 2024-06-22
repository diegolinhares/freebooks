class AddAuthorToBooks < ::ActiveRecord::Migration[7.1]
  def change
    remove_column :books, :author, :string

    add_reference :books, :author, null: false, foreign_key: true
  end
end
