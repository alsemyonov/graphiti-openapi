require "rails_helper"

RSpec.describe Graphiti::OpenAPI::Generator do
  subject(:instance) { described_class.new }

  its(:resources) { is_expected.to be_a Graphiti::OpenAPI::Resources }
  its(:endpoints) { is_expected.to be_a Hash }
  its(:types) { is_expected.to be_a Hash }

  describe "#to_openapi" do
    subject(:output) { instance.to_openapi(format: format) }

    context "(format: :yaml)" do
      let(:format) { :yaml }

      it { is_expected.to match /\Aopenapi:/ }
    end
  end
end
