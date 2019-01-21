RSpec.describe Graphiti::OpenAPI do
  it "is namespaced" do
    expect(Graphiti::OpenAPI).to be_a Module
  end

  it "has a version number" do
    expect(Graphiti::OpenAPI::VERSION).not_to be nil
  end
end
