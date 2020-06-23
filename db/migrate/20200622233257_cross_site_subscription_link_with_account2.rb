class CrossSiteSubscriptionLinkWithAccount2 < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :cross_site_subscriptions, :users, column: :created_by_id, on_delete: :nullify, validate: false
  end
end
