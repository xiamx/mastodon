class BackfillCrossSiteSubscriptionCreatedBy < ActiveRecord::Migration[5.2]
  def up
    CrossSiteSubscription.all.find_each do |sub|
      if User.find_by(id: sub.user_id)
        sub.created_by_id = sub.user_id
        sub.save!(validate: false)
      end
    end
  end
end
