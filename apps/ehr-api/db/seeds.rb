# apps/ehr-api/db/seeds.rb
# frozen_string_literal: true

Dir[Rails.root.join("db/seeds/*.rb")].sort.each { |f| load f }
