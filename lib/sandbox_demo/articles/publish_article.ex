defmodule SandboxDemo.Articles.PublishArticle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :article_id, Ecto.UUID
    field :author_id, Ecto.UUID
    field :title, :string
    field :body, :string
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:article_id, :author_id, :title, :body])
    |> validate_required([:article_id, :author_id, :title, :body])
    |> validate_length(:title, max: 120)
  end
end
