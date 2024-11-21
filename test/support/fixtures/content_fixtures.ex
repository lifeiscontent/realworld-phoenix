defmodule Realworld.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Realworld.Content` context.
  """

  @doc """
  Generate a unique article slug.
  """
  def unique_article_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a article.
  """
  def article_fixture(attrs \\ %{}) do
    {:ok, article} =
      attrs
      |> Enum.into(%{
        body: "some body",
        description: "some description",
        slug: unique_article_slug(),
        title: "some title"
      })
      |> Realworld.Content.create_article()

    article
  end
end
