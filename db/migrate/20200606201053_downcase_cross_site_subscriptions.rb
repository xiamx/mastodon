class DowncaseCrossSiteSubscriptions < ActiveRecord::Migration[5.2]
  def change
    CrossSiteSubscription.find_each do |sub|
      sub.foreign_user_id.downcase!
      sub.save!(validate: false)
    end
  end
end
