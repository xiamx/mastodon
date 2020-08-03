# frozen_string_literal: true

class UpdateInstagramPostsWorker
  include Sidekiq::Worker

  def perform(instagram_user_id)
    CrossSiteInstagram.new.update! instagram_user_id
  end
end
