# frozen_string_literal: true
class CrossSiteAccountCreator
  def initialize(subscription, options = {})
    @cross_site_subscription = subscription
    @site = subscription.site
    @screen_name = subscription.normalized_account_username
    @display_name = options[:display_name] || @screen_name
    @description = options[:description]
    @banner_uri = options[:banner_uri]
    @avatar_uri = options[:avatar_uri]
  end

  attr_reader :site, :screen_name, :description, :display_name, :banner_uri, :avatar_uri, :cross_site_subscription

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

  def current_account
    account = Account.find_by(username: screen_name)
    return account if account.present?

    nil
  end

  def create_if_not_exist
    return current_account if current_account.present?

    ApplicationRecord.transaction do
      account = Account.new(username: screen_name)
      password = SecureRandom.hex
      user     = User.new(
        email: "#{site}_#{SecureRandom.hex(10)}@m.gretaoto.ca",
        password: password,
        agreement: true,
        approved: true,
        admin: false,
        moderator: false,
        confirmed_at: nil
      )
      user.settings['default_sensitive'] = true if cross_site_subscription&.sensitive
      user.settings['default_privacy'] = :unlisted

      account.note = description.presence || "Cross-Site-Subscribed account: #{site} @#{screen_name}"
      account.display_name = display_name
      account.bot = true
      if site == 'twitter'
        account.fields = [
          {
            name: 'Twitter', value: "https://www.twitter.com/@#{screen_name}"
          }, {
            name: 'Status', value: 'Cross-Site-Subscribed account: unclaimed'
          }
        ]

      end

      if site == 'instagram'
        account.fields = [

          {
            name: 'Instagram', value: "https://www.instagram.com/#{cross_site_subscription.foreign_user_id}"
          }, {
            name: 'Status', value: 'Cross-Site-Subscribed account: unclaimed'
          }
        ]

      end
      account.header_remote_url = banner_uri if banner_uri.present?
      account.avatar_remote_url = avatar_uri if avatar_uri.present?

      account.suspended_at = nil
      user.account         = account
      user.skip_confirmation!
      user.confirm!
      user.approve!
      user.save!

      cross_site_subscription.account_id = account.id
      cross_site_subscription.save!(validate: false)

      account
    end
  end
end
