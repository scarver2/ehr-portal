# spec/support/spec_helpers.rb
# Shared helpers for test optimization and cleaner specs

module SpecHelpers
  # Clear Sidekiq jobs - use in after(:each) hooks
  def clear_sidekiq_jobs
    Sidekiq::Worker.clear_all
  end

  # Shared context for specs that use Sidekiq
  # Usage: include_context 'with sidekiq'
  def self.sidekiq_context
    RSpec.shared_context 'with sidekiq' do
      before { Sidekiq::Worker.clear_all }
      after { Sidekiq::Worker.clear_all }
    end
  end
end

RSpec.configure do |config|
  config.include SpecHelpers, type: :request
  config.include SpecHelpers, type: :model

  # Sidekiq shared context for specs that need it
  RSpec.shared_context 'with sidekiq' do
    before { Sidekiq::Worker.clear_all }
    after { Sidekiq::Worker.clear_all }
  end

  # Shared examples for GraphQL field validation
  RSpec.shared_examples 'a GraphQL field' do |field_name|
    subject { described_class.fields[field_name] }

    it { is_expected.to be_present }
    its(:name) { is_expected.to eq(field_name) }
  end

  RSpec.shared_examples 'a GraphQL list field' do |field_name|
    include_examples 'a GraphQL field', field_name
    specify { expect(subject.type.list?).to be true }
  end

  RSpec.shared_examples 'a GraphQL field with argument' do |field_name, arg_name|
    subject { described_class.fields[field_name] }

    specify do
      expect(subject.arguments.keys).to include(arg_name)
    end
  end
end
