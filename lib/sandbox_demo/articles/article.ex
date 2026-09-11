defmodule SandboxDemo.Articles.Article do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "articles" do
    field :title, :string
    field :body, :string
    belongs_to :author, SandboxDemo.Articles.Author
  end
end
