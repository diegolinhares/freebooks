class AddAvailableCopiesToBooks < ::ActiveRecord::Migration[7.1]
  def change
    add_column :books, :available_copies, :integer, null: false, default: 0
  end
end
