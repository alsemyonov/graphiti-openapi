require "rails_helper"

RSpec.describe "articles#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/api/v1/articles", params: params
  end

  describe "basic fetch" do
    let!(:article1) { create(:article) }
    let!(:article2) { create(:article) }

    it "works" do
      expect(ArticleResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.map(&:jsonapi_type).uniq).to match_array(["articles"])
      expect(d.map(&:id)).to match_array([article1.id, article2.id])
    end
  end
end
