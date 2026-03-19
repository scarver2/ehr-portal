# app/services/rte_cache.rb
# frozen_string_literal: true

class RteCache
  TTL = 12.hours

  def self.fetch(payer_code:, member_id:)
    Rails.cache.fetch(cache_key(payer_code, member_id), expires_in: TTL) do
      yield
    end
  end

  def self.write(payer_code:, member_id:, data:)
    Rails.cache.write(cache_key(payer_code, member_id), data, expires_in: TTL)
  end

  def self.read(payer_code:, member_id:)
    Rails.cache.read(cache_key(payer_code, member_id))
  end

  def self.invalidate(payer_code:, member_id:)
    Rails.cache.delete(cache_key(payer_code, member_id))
  end

  def self.cache_key(payer_code, member_id)
    "insurance:rte:#{payer_code}:#{member_id}"
  end
end
