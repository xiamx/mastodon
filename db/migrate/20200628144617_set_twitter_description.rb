class SetTwitterDescription < ActiveRecord::Migration[5.2]
  def change
    CrossSiteSubscription.where(site: "twitter").find_each do |sub|
      account = sub.account
      next if account.nil?

      account.note = "Mirrored twitter user. not #{sub.foreign_user_id} themself. #{account.note}"
      account.save!
    end
  end
end
