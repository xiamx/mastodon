# == Schema Information
#
# Table name: cross_site_subscriptions
#
#  id              :bigint(8)        not null, primary key
#  site            :string
#  foreign_user_id :string
#  state           :string
#  user_id         :bigint(8)        not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class CrossSiteSubscription < ApplicationRecord
  belongs_to :user

  def site_user_url
    if site == 'twitter'
      "https://www.twitter.com/#{foreign_user_id}"
    else
      '#'
    end
  end

  def pretty_acct
    if account.present?
      account.pretty_acct
    else
      foreign_user_id
    end
  end

  def account
    @_account ||= Account.find_by(username: foreign_user_id)
  end
end
