class CrossSiteSubscriptionLinkWithAccount < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :cross_site_subscriptions, :account, index: {algorithm: :concurrently}
  end
end
