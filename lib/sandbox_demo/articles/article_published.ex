defmodule SandboxDemo.Articles.ArticlePublished do
  @derive Jason.Encoder
  defstruct [:article_id, :author_id, :title, :body]
end
