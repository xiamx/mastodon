# frozen_string_literal: true
class CrossSiteAccountCreator
  def initialize(site, screen_name, options = {})
    @site = site
    @screen_name = screen_name.downcase.gsub('.', '_')
    @display_name = options[:display_name] || @screen_name
    @description = options[:description]
    @banner_uri = options[:banner_uri]
    @avatar_uri = options[:avatar_uri]
  end

  attr_reader :site, :screen_name, :description, :display_name, :banner_uri, :avatar_uri

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

  def formatted_screen_name
    "#{screen_name}_#{shorten_site}"
  end

  def current_account
    account = Account.find_by(username: screen_name)
    return account if account.present?

    account = Account.find_by(username: formatted_screen_name)
    return account if account.present?

    nil
  end

  def create_if_not_exist
    return current_account if current_account.present?

    cross_site_subscription = CrossSiteSubscription.find_by(site: 'twitter', foreign_user_id: screen_name)

    account = Account.new(username: formatted_screen_name)
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
    user.settings['default_privacy'] = :unlisted if cross_site_subscription&.sensitive

    account.note = description.presence || "Cross-Site-Subscribed account: #{site} @#{screen_name}"
    account.display_name = display_name
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
          name: 'Instagram', value: "https://www.instagram.com/#{screen_name}"
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

    account
  end
end
