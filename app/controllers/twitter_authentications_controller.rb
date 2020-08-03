# frozen_string_literal: true
class TwitterAuthenticationsController < ApplicationController
  layout 'admin'
  include Authorization
  before_action :authenticate_user!

  def new
    authorize :twitter_authentication, :create?
    @consumer = consummer
    @request_token = @consumer.get_request_token(
      oauth_callback: callback_twitter_authentications_url
    )
    redirect_to @request_token.authorize_url
  end

  def callback
    authorize :twitter_authentication, :create?
    @consumer = consummer
    oauth_token = params[:oauth_token]
    oauth_verifier = params[:oauth_verifier]
    token = OAuth::RequestToken.new(@consumer, token = oauth_token)
    access_token = token.get_access_token(
      oauth_verifier: oauth_verifier
    )

    TwitterAuthentication.create!(
      access_token: access_token.token,
      access_token_secret: access_token.secret,
      account: current_account
    )

    redirect_to cross_site_subscribes_path
  end

  private

  def consummer
    @consumer = OAuth::Consumer.new(
      ENV['TWITTER_CONSUMER_KEY'],
      ENV['TWITTER_CONSUMER_SECRET'],
      site: 'https://api.twitter.com'
    )
  end
end
