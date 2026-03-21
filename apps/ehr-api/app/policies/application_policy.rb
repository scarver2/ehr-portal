# apps/ehr-api/app/policies/application_policy.rb
# frozen_string_literal: true

# Base class for all Pundit authorization policies.
# Subclass this and override methods to define resource-specific rules.
# AdminUser model is for ActiveAdmin interface (separate from portal User model)
# Portal users are authenticated via JWT and may have roles: provider, staff, patient
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user   = user
    @record = record
  end

  # Default: deny access unless a specific policy grants it
  # Subclasses can override to grant access based on user roles
  def index?  = false
  def show?   = false
  def create? = false
  def new?    = create?
  def update? = false
  def edit?   = update?
  def destroy? = false

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
