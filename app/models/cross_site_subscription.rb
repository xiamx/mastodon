# frozen_string_literal: true
# == Schema Information
#
# Table name: cross_site_subscriptions
#
#  id              :bigint(8)        not null, primary key
#  site            :string
#  foreign_user_id :string
#  state           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sensitive       :boolean
#  account_id      :bigint(8)
#  created_by_id   :bigint(8)
#  public          :boolean
#
class CrossSiteSubscription < ApplicationRecord
  WHITELISTED_SITES = %w[twitter instagram]

  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :account, optional: true
  before_validation :downcase_fields!
  validates :foreign_user_id, uniqueness: { scope: :site, message: 'user already added for this site', case_sensitive: false }
  validate :valid_foreign_user

  before_validation do
    self.foreign_user_id = foreign_user_id[1..-1] if (site == 'twitter' || site == 'instagram') && foreign_user_id.start_with?('@')
  end

  def twitter?
    site == 'twitter'
  end

  def valid_foreign_user
    errors.add(:site, "Only Twitter and Instagram foreign user is supported") unless WHITELISTED_SITES.include?(site)
    errors.add(:foreign_user_id, "Can't find that twitter user") if twitter? && !CrossSiteTwitter.new.user_exists?(foreign_user_id)
  end

  def downcase_fields!
    foreign_user_id.downcase!
    site.downcase!
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

  def normalized_account_username
    case site
    when 'twitter'
      foreign_user_id.downcase.gsub('.', '_')
    when 'instagram'
      foreign_user_id.downcase.gsub('.', '_') + "_" + shorten_site
    else
      foreign_user_id.downcase
    end
  end

  def shorten_site
    case site
    when 'twitter'
      't'
    when 'instagram'
      'ig'
    else
      site
    end
  end
end
