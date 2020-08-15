class ValidateCrossSiteSubscriptionLinkWithAccount2 < ActiveRecord::Migration[5.2]
  def change
    def change
      validate_foreign_key :cross_site_subscriptions, :users
    end
  end
end
