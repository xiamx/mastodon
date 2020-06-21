# frozen_string_literal: true

class CrossSiteSubscriptionFilter
  KEYS = %i(
    relationship
    location
  ).freeze

  attr_reader :params, :user

  def initialize(user, params)
    @user = user
    @params  = params

    set_defaults!
  end

  def results
    scope = scope_for('relationship', params['relationship'].to_s.strip)

    params.each do |key, value|
      next if %w(relationship page).include?(key)

      scope.merge!(scope_for(key.to_s, value.to_s.strip)) if value.present?
    end

    scope
  end

  private

  def set_defaults!
    params['relationship'] = 'all' if params['relationship'].blank?
    params['location']     = 'all' if params['location'].blank?
  end

  def scope_for(key, value)
    case key
    when 'relationship'
      relationship_scope(value)
    when 'location'
      location_scope(value)
    else
      raise "Unknown filter: #{key}"
    end
  end

  def relationship_scope(value)
    case value
    when 'all'
      CrossSiteSubscription.all
    when 'added_by_me'
      CrossSiteSubscription.where(user: user)
    else
      raise "Unknown relationship: #{value}"
    end
  end

  def location_scope(value)
    case value
    when 'all'
      CrossSiteSubscription.all
    when 'twitter', 'instagram'
      CrossSiteSubscription.where(site: value)
    else
      raise "Unknown site: #{value}"
    end
  end
end
