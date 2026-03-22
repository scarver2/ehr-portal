class AdminUser < ApplicationRecord
  devise :database_authenticatable, :validatable
end
