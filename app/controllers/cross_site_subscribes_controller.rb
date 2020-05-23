class CrossSiteSubscribesController < ApplicationController
  include Authorization

  layout 'admin'

  before_action :authenticate_user!

  def index
    @cross_site_subscriptions = subscription_list
    render :index
  end

  def new
    render :'errors/400' if params[:site] != 'twitter'
    @cross_site_subscription = CrossSiteSubscription.new(site: 'twitter')
  end

  def create
    authorize :cross_site_subscribe, :create?

    @cross_site_subscription      = CrossSiteSubscription.new(resource_params)
    @cross_site_subscription.user = current_user

    render :'errors/400' if resource_params[:site] != 'twitter'

    if @cross_site_subscription.save
      redirect_to cross_site_subscribes_path
    else
      @cross_site_subscriptions = subscription_list
      render :index
    end
  end

  def destroy

  end

  private

  def subscription_list
    CrossSiteSubscription.all.page(params[:page]).per(20)
  end

  def resource_params
    params.require(:cross_site_subscription).permit(:site, :foreign_user_id)
  end


end
