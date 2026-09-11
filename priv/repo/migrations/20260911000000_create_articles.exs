defmodule SandboxDemo.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:authors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :text, null: false
    end

    create table(:articles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :author_id, references(:authors, type: :binary_id), null: false
      add :title, :text, null: false
      add :body, :text, null: false
    end

    create index(:articles, [:author_id])

    create table(:projection_versions, primary_key: false) do
      add :projection_name, :text, primary_key: true
      add :last_seen_event_number, :bigint
      timestamps(type: :naive_datetime_usec)
    end
  end
end
