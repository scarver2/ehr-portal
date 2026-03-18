# apps/ehr-api/app/policies/application_policy.rb
# frozen_string_literal: true

# Base class for all Pundit authorization policies.
# Subclass this and override methods to define resource-specific rules.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user   = user
    @record = record
  end

  def index?  = user.admin?
  def show?   = user.admin?
  def create? = user.admin?
  def new?    = create?
  def update? = user.admin?
  def edit?   = update?
  def destroy? = user.admin?

  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve = raise NotImplementedError, "#{self.class}#resolve is not implemented"

    private

    attr_reader :user, :scope
  end
end
