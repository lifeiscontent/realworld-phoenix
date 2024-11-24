defmodule Realworld.ContentTest do
  use Realworld.DataCase

  alias Realworld.Content
  alias Realworld.Content.Article
  alias Realworld.Accounts.User
  alias Realworld.Policy
  import Realworld.ContentFixtures
  import Realworld.AccountsFixtures

  describe "articles" do
    @valid_attrs %{description: "some description", title: "some title", body: "some body", slug: "some slug"}
    @update_attrs %{description: "some updated description", title: "some updated title", body: "some updated body", slug: "some updated slug"}
    @invalid_attrs %{description: nil, title: nil, body: nil, slug: nil}

    test "list_articles/0 returns all articles" do
      article = article_fixture()
      assert Content.list_articles() == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert Content.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      user = user_fixture()
      valid_attrs = Map.put(@valid_attrs, :author_id, user.id)

      assert {:ok, %Article{} = article} = Content.create_article(valid_attrs)
      assert article.description == "some description"
      assert article.title == "some title"
      assert article.body == "some body"
      assert article.slug == "some slug"
      assert article.author_id == user.id
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()
      assert {:ok, %Article{} = article} = Content.update_article(article, @update_attrs)
      assert article.description == "some updated description"
      assert article.title == "some updated title"
      assert article.body == "some updated body"
      assert article.slug == "some updated slug"
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_article(article, @invalid_attrs)
      assert article == Content.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = Content.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Content.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = Content.change_article(article)
    end
  end

  describe "authorization" do
    test "allows anyone to list articles" do
      assert Policy.allowed_to?(Content, :list_articles, nil)
    end

    test "allows anyone to read articles" do
      article = %Article{id: 1}
      assert Policy.allowed_to?(Content, :read_article, nil, article)
    end

    test "requires authentication for creating articles" do
      refute Policy.allowed_to?(Content, :create_article, nil)
      assert Policy.allowed_to?(Content, :create_article, %User{id: 1})
    end

    test "allows users to update their own articles" do
      user = %User{id: 1}
      article = %Article{id: 1, author_id: 1}

      assert Policy.allowed_to?(Content, :update_article, user, article)
      refute Policy.allowed_to?(Content, :update_article, nil, article)
      refute Policy.allowed_to?(Content, :update_article, %User{id: 2}, article)
    end

    test "allows users to delete their own articles" do
      user = %User{id: 1}
      article = %Article{id: 1, author_id: 1}

      assert Policy.allowed_to?(Content, :delete_article, user, article)
      refute Policy.allowed_to?(Content, :delete_article, nil, article)
      refute Policy.allowed_to?(Content, :delete_article, %User{id: 2}, article)
    end
  end
end
