# == Schema Information
#
# Table name: instagram_posts
#
#  id           :bigint(8)        not null, primary key
#  post_id      :string           not null
#  account_id   :bigint(8)
#  post_url     :string
#  full_text    :string
#  payload      :jsonb
#  published_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class InstagramPost < ApplicationRecord
  belongs_to :account

  scope :unpublished, -> { where("published_at is not null") }

  def publish!
    self.published_at = Time.now.utc
    self.save!
  end

  def published?
    ! self.published_at.nil?
  end
end
