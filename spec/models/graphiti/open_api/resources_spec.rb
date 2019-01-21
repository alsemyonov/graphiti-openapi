require "rails_helper"

RSpec.describe Graphiti::OpenAPI::Resources do
  subject(:instance) { Graphiti::OpenAPI::Generator.new.resources }

  describe "#by_model" do
    subject { instance.method(:by_model) }

    its(["Article"]) { is_expected.to be_a Graphiti::OpenAPI::Resource }
  end
end
