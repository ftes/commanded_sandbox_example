defmodule SandboxDemo.Articles.Author do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "authors" do
    field :name, :string
  end
end
