class CreateInstagramPosts < ActiveRecord::Migration[5.2]
  def change
    create_table :instagram_posts do |t|
      t.string :post_id, null: false
      t.references :account, foreign_key: { on_delete: :cascade }
      t.string :post_url
      t.string :full_text
      t.jsonb :payload
      t.timestamp :published_at
      t.timestamps
    end
  end
end
