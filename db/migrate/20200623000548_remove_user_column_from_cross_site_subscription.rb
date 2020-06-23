class RemoveUserColumnFromCrossSiteSubscription < ActiveRecord::Migration[5.2]
  def change
    safety_assured {remove_column :cross_site_subscriptions, :user_id}
  end
end
