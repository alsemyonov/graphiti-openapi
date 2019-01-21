require "rails_helper"

RSpec.describe ArticleResource, type: :resource do
  describe "creating" do
    let(:payload) do
      {
        data: {
          type: "articles",
          attributes: {},
        },
      }
    end

    let(:instance) do
      ArticleResource.build(payload)
    end

    it "works" do
      expect {
        expect(instance.save).to eq(true)
      }.to change { Article.count }.by(1)
    end
  end

  describe "updating" do
    let!(:article) { create(:article) }

    let(:payload) do
      {
        data: {
          id: article.id.to_s,
          type: "articles",
          attributes: {}, # Todo!
        },
      }
    end

    let(:instance) do
      ArticleResource.find(payload)
    end

    xit "works (add some attributes and enable this spec)" do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { article.reload.updated_at }
      # .and change { article.foo }.to('bar') <- example
    end
  end

  describe "destroying" do
    let!(:article) { create(:article) }

    let(:instance) do
      ArticleResource.find(id: article.id)
    end

    it "works" do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { Article.count }.by(-1)
    end
  end
end
