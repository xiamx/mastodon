# frozen_string_literal: true

class Scheduler::UpdateTweetsScheduler
  include Sidekiq::Worker

  sidekiq_options retry: true

  def perform
    CrossSiteTwitter.new.update!
  end
end
