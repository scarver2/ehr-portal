class RemoveDeviseColumnsFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :encrypted_password, :string if column_exists?(:users, :encrypted_password)
    remove_column :users, :reset_password_token, :string if column_exists?(:users, :reset_password_token)
    remove_column :users, :reset_password_sent_at, :datetime if column_exists?(:users, :reset_password_sent_at)
    remove_column :users, :remember_created_at, :datetime if column_exists?(:users, :remember_created_at)
    remove_column :users, :role, :string if column_exists?(:users, :role)
  end
end
