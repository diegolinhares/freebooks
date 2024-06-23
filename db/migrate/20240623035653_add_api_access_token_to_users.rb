class AddApiAccessTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :api_access_token, :string, null: false

    add_index :users, :api_access_token, unique: true
  end
end
