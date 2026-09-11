defmodule SandboxDemo.Articles.Projector do
  use Commanded.Projections.Ecto,
    application: SandboxDemo,
    name: "articles",
    repo: SandboxDemo.Repo,
    consistency: :strong

  alias SandboxDemo.Articles.{Article, ArticlePublished}

  # Commanded calls this in the projector process, including after a restart.
  @impl Commanded.Event.Handler
  def after_start(%{on_start: on_start}), do: on_start.()
  def after_start(_state), do: :ok

  project(%ArticlePublished{} = event, fn multi ->
    Ecto.Multi.insert(multi, :article, %Article{
      id: event.article_id,
      author_id: event.author_id,
      title: event.title,
      body: event.body
    })
  end)

  @impl Commanded.Projections.Ecto
  def after_update(%ArticlePublished{article_id: id}, _metadata, _changes) do
    Commanded.PubSub.broadcast(SandboxDemo.application(), "articles", {:article_published, id})
  end
end
