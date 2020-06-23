class BackfillCrossSiteSubscriptionAccount < ActiveRecord::Migration[5.2]
  def up
    CrossSiteSubscription.all.find_each do |sub|
      account = Account.find_by(username: sub.normalized_account_username)
      sub.account_id = account.id
      sub.save!
    end
  end
end
