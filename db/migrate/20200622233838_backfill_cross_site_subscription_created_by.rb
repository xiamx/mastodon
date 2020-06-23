class BackfillCrossSiteSubscriptionCreatedBy < ActiveRecord::Migration[5.2]
  def up
    CrossSiteSubscription.all.find_each do |sub|
      sub.created_by = sub.user
      sub.save!(validate: false)
    end
  end
end
