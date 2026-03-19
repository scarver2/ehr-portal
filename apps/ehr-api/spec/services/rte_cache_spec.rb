# spec/services/rte_cache_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe RteCache do
  let(:payer_code) { "AETNA001" }
  let(:member_id)  { "MBR0000001" }
  let(:data)       { { payer_name: "Aetna", copay_cents: 2500 } }

  before do
    @mem_store = ActiveSupport::Cache::MemoryStore.new
    allow(Rails).to receive(:cache).and_return(@mem_store)
  end

  describe ".cache_key" do
    it "builds the canonical key format" do
      expect(described_class.cache_key(payer_code, member_id))
        .to eq("insurance:rte:#{payer_code}:#{member_id}")
    end
  end

  describe ".write and .read" do
    it "stores and retrieves data" do
      described_class.write(payer_code: payer_code, member_id: member_id, data: data)
      expect(described_class.read(payer_code: payer_code, member_id: member_id)).to eq(data)
    end
  end

  describe ".fetch" do
    it "executes the block on cache miss and stores the result" do
      result = described_class.fetch(payer_code: payer_code, member_id: member_id) { data }
      expect(result).to eq(data)
      expect(described_class.read(payer_code: payer_code, member_id: member_id)).to eq(data)
    end

    it "returns cached value on hit without executing block" do
      described_class.write(payer_code: payer_code, member_id: member_id, data: data)
      block_called = false
      result = described_class.fetch(payer_code: payer_code, member_id: member_id) { block_called = true }
      expect(block_called).to be false
      expect(result).to eq(data)
    end
  end

  describe ".invalidate" do
    it "deletes the cached entry" do
      described_class.write(payer_code: payer_code, member_id: member_id, data: data)
      described_class.invalidate(payer_code: payer_code, member_id: member_id)
      expect(described_class.read(payer_code: payer_code, member_id: member_id)).to be_nil
    end
  end
end
