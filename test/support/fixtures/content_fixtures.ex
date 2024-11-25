defmodule Realworld.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Realworld.Content` context.
  """

  import Realworld.AccountsFixtures

  @doc """
  Generate a unique article slug.
  """
  def unique_article_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a article.
  """
  def article_fixture(attrs \\ %{}) do
    author = attrs[:author] || user_fixture()

    {:ok, article} =
      attrs
      |> Enum.into(%{
        body: "some body",
        description: "some description",
        slug: unique_article_slug(),
        title: "some title",
        author_id: author.id
      })
      |> Realworld.Content.create_article()

    article
  end
end
