defmodule SandboxDemo.IsolationTest do
  use SandboxDemo.DataCase,
    async: true,
    parameterize: [%{author_name: "Alice"}, %{author_name: "Bob"}]

  alias Commanded.EventStore
  alias SandboxDemo.Articles.ArticlePublished

  # Both concurrently running parameter sets use exactly the same aggregate ID.
  # SQL rollback alone would not reset a shared Commanded aggregate or store.
  @article_id "11111111-1111-4111-8111-111111111111"

  test "starts with a fresh aggregate, event stream, and SQL projection", context do
    app = context.commanded_application
    assert SandboxDemo.application() == app
    assert Process.whereis(SandboxDemo.Supervisor)
    assert SandboxDemo.list_articles() == []
    assert EventStore.stream_forward(app, "article-#{@article_id}") == {:error, :stream_not_found}

    author = SandboxDemo.create_author(context.author_name)

    attrs = %{
      article_id: @article_id,
      author_id: author.id,
      title: context.author_name,
      body: "Hello"
    }

    assert :ok = SandboxDemo.publish_article(attrs)
    assert {:error, :already_published} = SandboxDemo.publish_article(attrs)

    assert [%{id: @article_id, title: title, author: %{name: name}}] = SandboxDemo.list_articles()
    assert title == context.author_name
    assert name == context.author_name

    assert [%{stream_version: 1, data: %ArticlePublished{title: ^title}}] =
             app |> EventStore.stream_forward("article-#{@article_id}") |> Enum.to_list()
  end
end
