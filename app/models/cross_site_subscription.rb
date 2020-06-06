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
  before_validation :downcase_fields!
  validates :foreign_user_id, uniqueness: { scope: :site, message: 'user already added for this site', case_sensitive: false}
  validate :valid_foreign_user

  before_validation do
    self.foreign_user_id = foreign_user_id[1..-1] if twitter? && foreign_user_id.start_with?('@')
  end

  def twitter?
    site == 'twitter'
  end

  def valid_foreign_user
    errors.add(:foreign_user_id, "Can't find that user") if twitter? && !CrossSiteTwitter.new.user_exists?(foreign_user_id)
  end

  def downcase_fields!
    self.foreign_user_id.downcase!
    self.site.downcase!
  end

  def site_user_url
    if twitter?
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
