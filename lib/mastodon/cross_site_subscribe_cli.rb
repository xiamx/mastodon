# frozen_string_literal: true
require 'set'
require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class CrossSiteSubscribeCli < Thor
    include CLIHelper

    def self.exit_on_failure?
      true
    end

    desc 'prune', 'prune all non followed user and those without created_by and have less than 2 followers'
    def prune
      CrossSiteSubscription.where(created_by: nil).select { |s| (s.account&.followers_count || 0) < 3 }.each(&:destroy)
      CrossSiteSubscription.all.select { |s| (s.account&.followers_count || 0) == 0 }.each(&:destroy)
      say('OK', :green)
    end

    desc 'remove', 'remove all old content (older than 14 days'
    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    def remove
      parallelize_with_progress(CrossSiteSubscription) do |sub|
        account = sub.account
        account.statuses.where("created_at < NOW() - interval '14 days'").find_each do | status |
          RemoveStatusService.new.call(status, immediate: true )
          say("Removing status #{status.id} of #{account.username}", :green)
        end
        next if account.nil?
      end
      say('OK', :green)
    end

    option :all, type: :boolean
    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    desc 'mute [SITE] [foreign_user_id]', 'mute a cross site subscribed user'
    def mute(site = nil, foreign_user_id = nil)
      if options[:all]
        where_clause = nil
      elsif !site.nil? && !foreign_user_id.nil?
        where_clause = { site: site, foreign_user_id: foreign_user_id.downcase }
      else
        say('No cross_site_subscription(s) given', :red)
        exit(1)
      end

      parallelize_with_progress(CrossSiteSubscription.where(where_clause)) do |sub|
        account = sub.account
        next if account.nil?

        user = account.user
        next if user.nil?

        next if user.settings['default_privacy'] == :unlisted

        user.settings['default_privacy'] = :unlisted
        user.save!

        say("Muted #{sub.site} #{sub.foreign_user_id}", :green)

        account.statuses.each do |status|
          status.visibility = :unlisted
          status.save!
        end
        say("All #{sub.site} #{sub.foreign_user_id} statuses are now unlisted", :green)
      end
      say('OK', :green)
    end
  end
end
