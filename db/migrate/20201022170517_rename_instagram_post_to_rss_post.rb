class RenameInstagramPostToRssPost < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_table :instagram_posts, :rss_posts
    end
  end
end
