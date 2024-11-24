defmodule Realworld.Content.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :description, :string
    field :title, :string
    field :body, :string
    field :slug, :string
    field :author_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :slug, :description, :body, :author_id])
    |> validate_required([:title, :slug, :description, :body, :author_id])
    |> unique_constraint(:slug)
  end
end
