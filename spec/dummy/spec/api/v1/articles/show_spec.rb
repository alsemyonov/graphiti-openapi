require "rails_helper"

RSpec.describe "articles#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/api/v1/articles/#{article.id}", params: params
  end

  describe "basic fetch" do
    let!(:article) { create(:article) }

    it "works" do
      expect(ArticleResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq("articles")
      expect(d.id).to eq(article.id)
    end
  end
end
