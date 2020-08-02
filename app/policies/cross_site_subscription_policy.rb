# frozen_string_literal: true

class CrossSiteSubscriptionPolicy < ApplicationPolicy
  def index?
    user_signed_in?
  end

  def new?
    user_signed_in?
  end

  def create?
    user_signed_in?
  end

  def destroy?
    staff?
  end

  def show_created_by?
    staff?
  end

  private

  def owner?
    record.user_id == current_user&.id
  end

end
