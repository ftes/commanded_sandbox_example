defmodule SandboxDemo do
  @moduledoc """
  The application's public API and Commanded entry point.

  There is one OTP application, `:sandbox_demo`. Phoenix's generated
  `SandboxDemo.Application` supervises the repo, endpoint, and this module.
  """
  use Commanded.Application, otp_app: :sandbox_demo

  alias SandboxDemo.Articles.{Article, Author, PublishArticle}
  alias SandboxDemo.Repo

  router(SandboxDemo.Router)

  # Keep calls qualified, including inside this module, so Mimic can intercept
  # them. A local application() call would bypass the test's stub.
  def application, do: __MODULE__

  def publish_article(attrs) do
    with {:ok, command} <-
           attrs |> PublishArticle.changeset() |> Ecto.Changeset.apply_action(:insert) do
      SandboxDemo.dispatch(command, application: SandboxDemo.application(), consistency: :strong)
    end
  end

  def list_articles do
    import Ecto.Query
    Repo.all(from article in Article, order_by: [asc: article.title], preload: [:author])
  end

  def list_authors do
    import Ecto.Query
    Repo.all(from author in Author, order_by: [asc: author.name])
  end

  def create_author(name) do
    %Author{} |> Ecto.Changeset.change(name: name) |> Repo.insert!()
  end

  def subscribe do
    Commanded.PubSub.subscribe(SandboxDemo.application(), "articles")
  end
end
