class CrossSiteSubscribesController < ApplicationController
  include Authorization

  layout 'admin'

  before_action :authenticate_user!, :fetch_current_twitter_account

  def index
    @cross_site_subscriptions = subscription_list
    render :index
  end

  def new
    render :'errors/400' unless CrossSiteSubscription::WHITELISTED_SITES.include?(params[:site])
    @cross_site_subscription = CrossSiteSubscription.new(site: params[:site])
  end

  def create
    authorize :cross_site_subscribe, :create?

    @cross_site_subscription      = CrossSiteSubscription.new(resource_params)
    @cross_site_subscription.user = current_user

    return render :'errors/400' unless CrossSiteSubscription::WHITELISTED_SITES.include?(@cross_site_subscription.site)

    return render :'errors/400' if @cross_site_subscription.site == 'instagram' && !Flipper.enabled?(:cross_site_instagram, current_user)

    CrossSiteSubscription.transaction(requires_new: true) do
      if @cross_site_subscription.save
        SubscribeCrossSiteUserService.new.call(@cross_site_subscription, current_account)
        return redirect_to action: :index
      else
        @cross_site_subscriptions = subscription_list
        raise ActiveRecord::Rollback
      end
    end
    render :new

  end

  def destroy

  end

  private

  def fetch_current_twitter_account
    @current_twitter_account = TwitterAuthentication.find_by(system_default: true)
  end

  def subscription_list
    CrossSiteSubscription.all.page(params[:page]).per(20)
  end

  def resource_params
    params.require(:cross_site_subscription).permit(:site, :foreign_user_id, :sensitive)
  end


end
