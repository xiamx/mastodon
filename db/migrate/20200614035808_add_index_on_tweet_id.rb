class AddIndexOnTweetId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :tweets, :tweet_id, unique: true, algorithm: :concurrently
  end
end
