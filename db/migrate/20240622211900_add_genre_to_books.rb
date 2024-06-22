class AddGenreToBooks < ::ActiveRecord::Migration[7.1]
  def change
    remove_column :books, :genre, :string

    add_reference :books, :genre, null: false, foreign_key: true
  end
end
