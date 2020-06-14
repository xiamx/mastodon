# frozen_string_literal: true

class Scheduler::UpdateInstagramPosts
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, retry: 0

  def perform
    CrossSiteInstagram.new.update_all!
  end
end
