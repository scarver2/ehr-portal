# spec/routing/routes_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Routes' do
  # ── GraphQL ───────────────────────────────────────────────────────────────
  describe 'GraphQL' do
    it 'routes POST /graphql' do
      expect(post: '/graphql').to route_to('graphql#execute')
    end

    it 'does not route GET /graphql' do
      expect(get: '/graphql').not_to be_routable
    end
  end

  # ── GraphiQL (development only) ───────────────────────────────────────────
  describe 'GraphiQL' do
    it 'is not routable outside the development environment' do
      expect(get: '/graphiql').not_to be_routable
    end
  end

  # ── Devise / Auth (via ActiveAdmin::Devise.config) ────────────────────────
  describe 'Devise sessions (mounted under /admin)' do
    it 'routes GET /admin/login to sessions#new' do
      expect(get: '/admin/login').to route_to('active_admin/devise/sessions#new')
    end

    it 'routes POST /admin/login to sessions#create' do
      expect(post: '/admin/login').to route_to('active_admin/devise/sessions#create')
    end

    it 'routes DELETE /admin/logout to sessions#destroy' do
      expect(delete: '/admin/logout').to route_to('active_admin/devise/sessions#destroy')
    end
  end

  describe 'Devise passwords' do
    it 'routes GET /admin/password/new' do
      expect(get: '/admin/password/new').to route_to('active_admin/devise/passwords#new')
    end

    it 'routes GET /admin/password/edit' do
      expect(get: '/admin/password/edit').to route_to('active_admin/devise/passwords#edit')
    end

    it 'routes POST /admin/password' do
      expect(post: '/admin/password').to route_to('active_admin/devise/passwords#create')
    end
  end

  # ── ActiveAdmin ───────────────────────────────────────────────────────────
  describe 'ActiveAdmin dashboard' do
    it 'routes GET /admin to dashboard#index' do
      expect(get: '/admin').to route_to('admin/dashboard#index')
    end
  end

  describe 'ActiveAdmin providers' do
    it 'routes GET /admin/providers' do
      expect(get: '/admin/providers').to route_to('admin/providers#index')
    end

    it 'routes GET /admin/providers/new' do
      expect(get: '/admin/providers/new').to route_to('admin/providers#new')
    end

    it 'routes POST /admin/providers' do
      expect(post: '/admin/providers').to route_to('admin/providers#create')
    end

    it 'routes GET /admin/providers/:id' do
      expect(get: '/admin/providers/1').to route_to('admin/providers#show', id: '1')
    end

    it 'routes GET /admin/providers/:id/edit' do
      expect(get: '/admin/providers/1/edit').to route_to('admin/providers#edit', id: '1')
    end

    it 'routes PATCH /admin/providers/:id' do
      expect(patch: '/admin/providers/1').to route_to('admin/providers#update', id: '1')
    end

    it 'routes DELETE /admin/providers/:id' do
      expect(delete: '/admin/providers/1').to route_to('admin/providers#destroy', id: '1')
    end
  end
end
