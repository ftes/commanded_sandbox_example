defmodule SandboxDemoWeb.ArticlesBrowserTest do
  use SandboxDemoWeb.BrowserCase,
    async: true,
    parameterize: [%{author_name: "Alice"}, %{author_name: "Bob"}]

  alias Commanded.EventStore

  test "HTTP, LiveView, and projector share this test's transaction and application", context do
    # This author is uncommitted SQL data created by the test process.
    author = SandboxDemo.create_author(context.author_name)
    title = "A story by #{author.name}"

    browser =
      context.conn
      |> visit(~p"/articles")
      |> assert_has(".phx-connected")
      |> select("Author", option: author.name, exact: false)
      |> fill_in("Title", with: title)
      |> fill_in("Story", with: "Written in a real Chromium browser.")
      |> click_button("Publish article")
      |> assert_has("#articles article h3", text: title)

    assert [%{id: id, author_id: author_id, title: ^title}] = SandboxDemo.list_articles()
    assert author_id == author.id

    assert [%{stream_version: 1}] =
             context.commanded_application
             |> EventStore.stream_forward("article-#{id}")
             |> Enum.to_list()

    # Publishing from the test must reach the already-connected browser via
    # this application's projector and PubSub, without reloading the page.
    assert :ok =
             SandboxDemo.publish_article(%{
               article_id: Ecto.UUID.generate(),
               author_id: author.id,
               title: "An update for #{author.name}",
               body: "Published from the test process."
             })

    assert_has(browser, "#articles article h3", text: "An update for #{author.name}")
    assert length(SandboxDemo.list_articles()) == 2
    assert Enum.all?(SandboxDemo.list_articles(), &(&1.author_id == author.id))
  end
end
