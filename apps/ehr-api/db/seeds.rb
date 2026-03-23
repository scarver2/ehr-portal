# apps/ehr-api/db/seeds.rb
# frozen_string_literal: true

Rails.root.glob('db/seeds/*.rb').each { |f| load f }
