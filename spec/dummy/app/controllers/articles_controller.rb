class ArticlesController < ApplicationController
  def index
    articles = ArticleResource.all(params)
    respond_with(articles)
  end

  def show
    article = ArticleResource.find(params)
    respond_with(article)
  end

  def create
    article = ArticleResource.build(params)

    if article.save
      render jsonapi: article, status: 201
    else
      render jsonapi_errors: article
    end
  end

  def update
    article = ArticleResource.find(params)

    if article.update_attributes
      render jsonapi: article
    else
      render jsonapi_errors: article
    end
  end

  def destroy
    article = ArticleResource.find(params)

    if article.destroy
      render jsonapi: {meta: {}}, status: 200
    else
      render jsonapi_errors: article
    end
  end
end
