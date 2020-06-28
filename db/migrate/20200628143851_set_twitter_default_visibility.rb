class SetTwitterDefaultVisibility < ActiveRecord::Migration[5.2]
  def change
    CrossSiteSubscription.all.find_each do |sub|
      account = sub.account
      next if account.nil?

      user = account.user
      next if user.nil?

      user.settings['default_privacy'] = :unlisted
      user.save!

      account.bot = true
      account.display_name = "#{account.display_name[0..18]} (mirrored)"
      account.save!
    end
  end
end
