class PopulateTwitterAccountNotes < ActiveRecord::Migration[5.2]
  def up
    Tweet.find_each do |tweet_db_obj|
      payload = JSON.parse(tweet_db_obj.payload, symbolize_names: true)
      tweet = Twitter::Tweet.new(payload)
      tweet_user = tweet.user
      account = Account.find_by(username: tweet_user.screen_name)
      account.note = tweet_user.description
      account.display_name = tweet_user.name
      account.fields = [
          {
              name: "Twitter", value: "https://www.twitter.com/@#{account.username}"
          },
          {
              name: "Status", value: "Cross-Site-Subscribed account: unclaimed"
          }
      ]
      account.header_remote_url = tweet_user.profile_banner_uri_https if tweet_user.profile_banner_uri?
      account.avatar_remote_url = tweet_user.profile_image_uri_https if tweet_user.profile_image_uri?
      account.save!
    end
  end

  def down ; end
end
