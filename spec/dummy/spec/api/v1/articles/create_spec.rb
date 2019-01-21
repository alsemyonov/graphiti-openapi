require "rails_helper"

RSpec.describe "articles#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/api/v1/articles", payload
  end

  describe "basic create" do
    let(:payload) do
      {
        data: {
          type: "articles",
          attributes: attributes_for(:article)
        },
      }
    end

    it "works" do
      expect(ArticleResource).to receive(:build).and_call_original
      expect {
        make_request
      }.to change { Article.count }.by(1)
      expect(response.status).to eq(201)
    end
  end
end
