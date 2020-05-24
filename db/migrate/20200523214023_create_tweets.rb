class CreateTweets < ActiveRecord::Migration[5.2]
  def change
    create_table :tweets do |t|
      t.column :tweet_id, 'bigint', null: false
      t.references :account, foreign_key: { on_delete: :cascade }
      t.string :full_text
      t.boolean :published, null: false, default: false
      t.jsonb :payload
      t.timestamps
    end
  end
end
