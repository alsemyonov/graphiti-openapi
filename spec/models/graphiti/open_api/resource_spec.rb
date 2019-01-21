require "rails_helper"

RSpec.describe Graphiti::OpenAPI::Resource do
  subject(:instance) { Graphiti::OpenAPI::Generator.new.resources.by_model("Article") }

  it { is_expected.to be_a described_class }
end
