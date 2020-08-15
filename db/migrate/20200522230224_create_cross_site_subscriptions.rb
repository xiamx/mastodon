class CreateCrossSiteSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :cross_site_subscriptions do |t|
      t.string :site
      t.string :foreign_user_id
      t.string :state
      t.bigint "user_id", null: false, index: true
      t.timestamps
    end

  end
end
