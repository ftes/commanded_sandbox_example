defmodule SandboxDemo.Articles.Aggregate do
  alias SandboxDemo.Articles.{ArticlePublished, PublishArticle}

  defstruct [:article_id]

  def execute(%__MODULE__{article_id: nil}, %PublishArticle{} = command) do
    struct!(ArticlePublished, Map.take(command, [:article_id, :author_id, :title, :body]))
  end

  def execute(%__MODULE__{}, %PublishArticle{}), do: {:error, :already_published}

  def apply(%__MODULE__{} = state, %ArticlePublished{article_id: id}) do
    %{state | article_id: id}
  end
end
