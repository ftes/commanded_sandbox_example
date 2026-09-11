defmodule SandboxDemoWeb.ArticlesLive do
  use SandboxDemoWeb, :live_view

  alias SandboxDemo.Articles.PublishArticle

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: SandboxDemo.subscribe()

    {:ok,
     socket
     |> assign(:authors, SandboxDemo.list_authors())
     |> assign(:page_title, "Articles")
     |> assign(:form, new_form())
     |> stream(:articles, SandboxDemo.list_articles())}
  end

  @impl true
  def handle_event("publish", %{"article" => attrs}, socket) do
    case SandboxDemo.publish_article(attrs) do
      :ok ->
        # The projector broadcasts after writing SQL. handle_info/2 updates
        # the list, exercising Commanded PubSub in the same isolated scope.
        {:noreply, socket |> assign(:form, new_form()) |> put_flash(:info, "Article published")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :article))}

      {:error, :already_published} ->
        {:noreply, put_flash(socket, :error, "This article has already been published")}
    end
  end

  @impl true
  def handle_info({:article_published, _id}, socket) do
    {:noreply, stream(socket, :articles, SandboxDemo.list_articles(), reset: true)}
  end

  # The SQL sandbox traps exits, while Commanded's local PubSub registry links
  # subscribers. Honor that link when the test's application shuts down.
  def handle_info({:EXIT, _pid, :shutdown}, _socket), do: exit(:shutdown)

  defp new_form do
    %{article_id: Ecto.UUID.generate()}
    |> PublishArticle.changeset()
    |> to_form(as: :article)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app {Map.take(assigns, ~w(flash current_user active_path static_assets_changed?)a)}>
      <div class="space-y-10">
        <div>
          <p class="text-sm font-medium uppercase tracking-widest text-orange-600">
            The reading room
          </p>
          <h1 class="mt-2 text-4xl font-semibold tracking-tight">Share a new story</h1>
          <p class="mt-3 text-base text-slate-500">Write something worth reading.</p>
        </div>

        <.form for={@form} id="article-form" phx-submit="publish" class="space-y-5">
          <.input field={@form[:article_id]} type="hidden" />
          <.input
            field={@form[:author_id]}
            type="select"
            label="Author"
            prompt="Choose an author"
            options={Enum.map(@authors, &{&1.name, &1.id})}
          />
          <.input field={@form[:title]} type="text" label="Title" required />
          <.input field={@form[:body]} type="textarea" label="Story" required />
          <button
            id="publish-article"
            type="submit"
            class="rounded-lg bg-orange-600 px-5 py-3 font-semibold text-white transition hover:bg-orange-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-orange-600"
          >
            Publish article
          </button>
        </.form>

        <section aria-labelledby="published-heading">
          <h2 id="published-heading" class="text-xl font-semibold">Published stories</h2>
          <div id="articles" phx-update="stream" class="mt-4 space-y-4">
            <p id="empty-articles" class="hidden only:block text-slate-500">
              Your first story starts here.
            </p>
            <article
              :for={{dom_id, article} <- @streams.articles}
              id={dom_id}
              class="rounded-xl border border-slate-200 p-6"
            >
              <h3 class="text-lg font-semibold">{article.title}</h3>
              <p class="mt-1 text-sm text-slate-500">By {article.author.name}</p>
              <p class="mt-4 whitespace-pre-wrap">{article.body}</p>
            </article>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
