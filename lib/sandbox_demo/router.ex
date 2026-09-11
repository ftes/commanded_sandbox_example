defmodule SandboxDemo.Router do
  use Commanded.Commands.Router

  alias SandboxDemo.Articles.{Aggregate, PublishArticle}

  identify(Aggregate, by: :article_id, prefix: "article-")
  dispatch(PublishArticle, to: Aggregate)
end
