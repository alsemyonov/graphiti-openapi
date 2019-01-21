class ArticleResource < ApplicationResource
  attribute :title, :string
  attribute :content, :string
  attribute :published_at, :datetime
end
