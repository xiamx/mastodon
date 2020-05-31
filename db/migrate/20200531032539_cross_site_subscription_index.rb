class CrossSiteSubscriptionIndex < ActiveRecord::Migration[5.2]
  def change
    safety_assured {
      add_index :cross_site_subscriptions, [:site, :foreign_user_id], unique: true
    }
  end
end
