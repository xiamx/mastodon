# frozen_string_literal: true

class CrossSiteSubscribePolicy < ApplicationPolicy
  def index?
    user_signed_in?
  end

  def create?
    user_signed_in?
  end

  def destroy?
    owner? || (Setting.min_invite_role == 'admin' ? admin? : staff?)
  end

  private

  def owner?
    record.user_id == current_user&.id
  end

end
