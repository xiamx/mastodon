class CreateTwitterAuthentications < ActiveRecord::Migration[5.2]
  def change
    create_table :twitter_authentications do |t|
      t.string :access_token
      t.string :access_token_secret
      t.boolean :system_default
      t.references :account, index:true, foreign_key: true
      t.timestamps
    end
  end
end
