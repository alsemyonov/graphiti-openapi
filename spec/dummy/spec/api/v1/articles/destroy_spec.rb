require "rails_helper"

RSpec.describe "articles#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/api/v1/articles/#{article.id}"
  end

  describe "basic destroy" do
    let!(:article) { create(:article) }

    it "updates the resource" do
      expect(ArticleResource).to receive(:find).and_call_original
      expect { make_request }.to change { Article.count }.by(-1)
      expect { article.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response.status).to eq(200)
      expect(json).to eq("meta" => {})
    end
  end
end
