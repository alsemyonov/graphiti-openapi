require "rails_helper"

RSpec.describe ArticleResource, type: :resource do
  describe "serialization" do
    let!(:article) { create(:article) }

    it "works" do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(article.id)
      expect(data.jsonapi_type).to eq("articles")
    end
  end

  describe "filtering" do
    let!(:article1) { create(:article) }
    let!(:article2) { create(:article) }

    context "by id" do
      before do
        params[:filter] = {id: {eq: article2.id}}
      end

      it "works" do
        render
        expect(d.map(&:id)).to eq([article2.id])
      end
    end
  end

  describe "sorting" do
    describe "by id" do
      let!(:article1) { create(:article) }
      let!(:article2) { create(:article) }

      context "when ascending" do
        before do
          params[:sort] = "id"
        end

        it "works" do
          render
          expect(d.map(&:id)).to eq([
            article1.id,
            article2.id,
          ])
        end
      end

      context "when descending" do
        before do
          params[:sort] = "-id"
        end

        it "works" do
          render
          expect(d.map(&:id)).to eq([
            article2.id,
            article1.id,
          ])
        end
      end
    end
  end

  describe "sideloading" do
    # ... your tests ...
  end
end
