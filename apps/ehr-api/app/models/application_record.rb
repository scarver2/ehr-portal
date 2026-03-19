# apps/ehr-api/app/models/application_record.rb
# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  include GlobalID::Identification
end
