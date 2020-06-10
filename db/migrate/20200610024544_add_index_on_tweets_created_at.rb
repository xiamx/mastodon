class AddIndexOnTweetsCreatedAt < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :tweets, :created_at, algorithm: :concurrently
  end
end
