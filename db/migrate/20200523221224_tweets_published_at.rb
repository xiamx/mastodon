class TweetsPublishedAt < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :tweets, :published_at, :timestamp
      Tweet.where(published: true).update(published_at: Time.now.utc)
      remove_column :tweets, :published, :boolean
    end
  end
end
