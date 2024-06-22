class CreateAuthors < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :authors, :name, unique: true
  end
end
