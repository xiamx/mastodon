# frozen_string_literal: true

class TwitterAuthenticationPolicy < ApplicationPolicy
  def create?
    admin?
  end
end
