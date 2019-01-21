require "rails_helper"

RSpec.describe Graphiti::OpenAPI::Generator do
  subject(:instance) { described_class.new }

  its(:resources) { is_expected.to be_a Graphiti::OpenAPI::Resources }
  its(:endpoints) { is_expected.to be_a Hash }
  its(:types) { is_expected.to be_a Hash }
end
