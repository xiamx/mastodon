class BackfillCrossSiteSubscriptionAccount2 < ActiveRecord::Migration[5.2]
  def up
    CrossSiteSubscription.all.find_each do |sub|
      account = Account.find_by("LOWER(username) = ?", sub.normalized_account_username.downcase)
      if account.present?
        sub.account_id = account.id
        sub.save!(validate: false)
      end
    end
  end
end
