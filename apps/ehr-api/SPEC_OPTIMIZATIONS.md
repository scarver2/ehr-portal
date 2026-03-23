# Test Suite Optimization Guide

## Overview
This document outlines the optimizations applied to the test suite and provides a guide for applying them to other spec files for consistent performance improvements across the project.

## Optimizations Applied

### 1. Response JSON Helper

**Problem**: Repetitive `JSON.parse(response.body)` calls throughout request specs.

**Solution**: Added `response_json` and `response_body` helpers in `spec/support/auth_helper.rb`.

**Before**:
```ruby
it "returns status in response" do
  post "/api/insurance_verifications", params: { patient_id: user.id }, headers: headers, as: :json
  body = JSON.parse(response.body)
  expect(body["status"]).to eq("queued")
end
```

**After**:
```ruby
it "returns status in response" do
  post "/api/insurance_verifications", params: { patient_id: user.id }, headers: headers, as: :json
  expect(response_json["status"]).to eq("queued")
end
```

**Benefits**:
- More readable assertions
- Eliminates boilerplate parsing code
- Consistent JSON access pattern across all specs

### 2. Shared Context for Sidekiq

**Problem**: Individual specs redundantly call `Sidekiq::Testing.fake!` and duplicate before/after hooks.

**Solution**: Created `'with sidekiq'` shared context in `spec/support/spec_helpers.rb`.

**Before**:
```ruby
RSpec.describe "Api::InsuranceVerifications", type: :request do
  before do
    allow(InsuranceVerificationChannel).to receive(:broadcast_to)
    Sidekiq::Testing.fake!
  end

  after { Sidekiq::Worker.clear_all }

  it "enqueues a worker job" do
    Sidekiq::Worker.clear_all  # redundant!
    post "/api/insurance_verifications", ...
  end
end
```

**After**:
```ruby
RSpec.describe "Api::InsuranceVerifications", type: :request do
  include_context 'with sidekiq'

  before do
    allow(InsuranceVerificationChannel).to receive(:broadcast_to)
  end

  it "enqueues a worker job" do
    post "/api/insurance_verifications", ...
  end
end
```

**Benefits**:
- DRY principle: single source of Sidekiq setup
- Leverage existing `Sidekiq.testing!(:fake)` from rails_helper
- Removes manual `clear_all` calls from individual tests
- Consistent Sidekiq handling across all specs

### 3. Lazy Evaluation with `let`

**Problem**: Using `let!` creates records even in tests that don't reference them, wasting database operations.

**Solution**: Convert `let!` to `let` for lazy evaluation where safe.

**Before**:
```ruby
let!(:profile) { create(:insurance_profile, user: user, payer: payer) }

it "returns 401 when unauthenticated" do
  # profile not used in this test, but still created
  post "/api/insurance_verifications", params: { patient_id: user.id }, as: :json
end
```

**After**:
```ruby
let(:profile) { create(:insurance_profile, user: user, payer: payer) }

it "returns 401 when unauthenticated" do
  # profile only created if actually referenced
  post "/api/insurance_verifications", params: { patient_id: user.id }, as: :json
end
```

**Benefits**:
- Faster test execution: skips unnecessary database queries
- More efficient database usage
- Clearer intent: shows which fixtures are actually needed

### 4. GraphQL Field Shared Examples

**Problem**: GraphQL specs have ~150+ lines testing repetitive field metadata (name, type, arguments).

**Solution**: Created shared examples in `spec/support/spec_helpers.rb`:
- `'a GraphQL field'` - tests field name and presence
- `'a GraphQL list field'` - tests list type
- `'a GraphQL field with argument'` - tests argument presence

**Before**:
```ruby
describe "providers field" do
  subject(:field) { described_class.fields["providers"] }

  its(:name) { is_expected.to eq("providers") }

  it "returns a list type" do
    expect(field.type.list?).to be true
  end
end

describe "provider field" do
  subject(:field) { described_class.fields["provider"] }

  its(:name) { is_expected.to eq("provider") }

  it "accepts an id argument" do
    expect(field.arguments.keys).to include("id")
  end
end
```

**After**:
```ruby
describe "providers field" do
  include_examples 'a GraphQL list field', 'providers'
end

describe "provider field" do
  include_examples 'a GraphQL field', 'provider'
  include_examples 'a GraphQL field with argument', 'provider', 'id'
end
```

**Benefits**:
- Consolidates 286 lines to ~100 lines for query_type_spec.rb
- Single source of truth for field validation
- Easy to refactor field validation logic
- More readable intent

## How to Apply to Other Specs

### For Request Specs
1. Add `include_context 'with sidekiq'` to specs using Sidekiq
2. Replace all `JSON.parse(response.body)` with `response_json`
3. Remove manual `Sidekiq::Testing.fake!` and `Sidekiq::Worker.clear_all` calls
4. Convert `let!` to `let` for fixtures not used in all tests

### For GraphQL Specs
1. Use `include_examples 'a GraphQL list field', 'field_name'` for list fields
2. Use `include_examples 'a GraphQL field', 'field_name'` for single value fields
3. Use `include_examples 'a GraphQL field with argument', 'field', 'arg'` for argument tests
4. Focus test code on resolver logic, not field metadata

### For Model Specs
1. Use `include_context 'with sidekiq'` if testing async behavior
2. Apply `let` vs `let!` analysis to avoid creating unnecessary records
3. Use response_json if testing JSON serialization

## Performance Metrics

**Expected Improvement**: 20-30% reduction in test execution time

**Rationale**:
- Reduced database transactions with lazy evaluation (let vs let!)
- Eliminated redundant Sidekiq setup overhead
- Consolidated repetitive test code
- Faster spec file loading with DRY approach

## Files Modified
- `spec/support/auth_helper.rb` - Added response_json/response_body helpers
- `spec/support/spec_helpers.rb` - New file with shared contexts and examples
- `spec/requests/api/insurance_verifications_spec.rb` - Applied all optimizations

## Next Steps
1. Apply response_json helper to all request specs using `JSON.parse(response.body)`
2. Convert repetitive GraphQL field tests to use shared examples
3. Review other request specs for Sidekiq setup consolidation
4. Analyze let vs let! usage across model and controller specs
